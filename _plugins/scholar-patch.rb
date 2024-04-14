module Jekyll
  class Scholar
    module Utilities
      alias_method :old_citation, :render_citation
      include BibTeX

      @@sep=","
      @@r_sep="-"

      @@me = "Godin-Dubois, K."
      @@link = '<i class="fa fa-external-link"></i>'

      @@tooltips = []

      def citation_start(numeric, ct_id)
          span = "<span class=\"citation-span"
          if numeric
            span << " citation-numeric"
          end
          span << "\" target-ctid=\"#{ct_id}\">"
      end
      @@citation_end = "</span>"

      def cite_attributes
        {class: config['cite_class']}
      end

      def format_range(group)
        case group.size
        when 1
            "#{group[0]}"
        when 2
            group.join(@@sep)
        else
            "#{group[0]}#{@@r_sep}#{group[-1]}"
        end
      end

      def items_in_citation(citation)
        begin_span_end = citation.index('>')
        end_span_start = citation.index('<', begin_span_end)
        items_id = citation[begin_span_end+1..end_span_start-1].split(@@sep)
        return begin_span_end, end_span_start, items_id
      end

      def render_citation(items)
        citation = old_citation(items)
        if items.size > 1
            begin_span_end, end_span_start, items_id = items_in_citation(citation)
            items_id = items_id.map(&:to_i).sort

            items_groups = [[items_id[0].to_i]]
            j = 0

            1.upto items_id.size - 1 do |i|
                id = items_id[i].to_i
                if id == items_groups[j][-1] + 1
                    items_groups[j].append(id)
                else
                    items_groups.append([id])
                    j += 1
                end
            end

            items_merged = items_groups.map{|g| format_range(g)}.join(@@sep)
            citation = citation[0..begin_span_end] + items_merged + citation[end_span_start..-1]
        end
        citation
      end

      def generate_citation_tooltip(items)
          id = "citation-tooltip-id#{@@tooltips.size}"
          tooltip = ""
          tooltip << "<div class=\"citation-tooltip\" id=\"#{id}\">\n"
          tooltip << "  <div class=\"citation-tooltip-content bibliography\">\n"
          tooltip << "    <table>\n"
          tooltip << items.map {
              |item| "      <tr>\n" \
                     "        <td><a href=\"##{item.key}\">#{citation_number(item.key)}</a>.</td>\n" \
                     "        <td>#{reference_tag(item).sub(/ id="[^"]+"/, '')}</td>\n" \
                     "      </tr>\n"
          }.join("\n")
          tooltip << "    </table>\n"
          tooltip << "  </div>\n"
          tooltip << "</div>\n"
          @@tooltips.append(tooltip)
#           p tooltip
          return id
      end

      alias_method :old_citer, :cite
      def cite(keys)
        items = keys.map do |key|
          if bibliography.key?(key)
            entry = bibliography[key]
            entry = entry.convert(*bibtex_filters) unless bibtex_filters.empty?
          else
            return missing_reference
          end
        end

        citation = render_citation(items)
        begin_span_end, end_span_start, items_id = items_in_citation(citation)

        ct_id = generate_citation_tooltip(items)

        citation = citation_start(numeric=true, ct_id=ct_id)
        citation << items_id.join(@@sep)
        citation << @@citation_end

#         p citation
        return citation
      end

      alias_method :old_render_bibliography, :render_bibliography
      def render_bibliography(entry, index = nil)
        bib_item = old_render_bibliography(entry, index)
        if entry.respond_to? :doi
            bib_item << " <a href=\"https://doi.org/#{entry.doi}\">#{@@link}</a>"
        elsif entry.respond_to? :url
            bib_item << " <a href=\"#{entry.url}\">#{@@link}</a>"
        end

        href = ""
        if bib_item.include? @@me
          href = "<a href=\"/publications##{entry.key}\">#{@@me}</a>"
          bib_item.sub!(@@me, href)
        end

        return bib_item
      end
    end

    class BibliographyTag
       include Utilities

       alias_method :old_render, :render
       def render(context)
#           puts "Rendering bibliography"
          biblio = old_render(context)
          biblio << @@tooltips.join("\n")
          @@tooltips = []
          return biblio
       end
    end

    class CiteAuthorTag < Liquid::Tag
      include Scholar::Utilities

      def initialize(tag_name, arguments, tokens)
        super

        @config = Scholar.defaults.dup
        @keys, arguments = split_arguments(arguments)

        optparse(arguments)
      end

      def render(context)
        set_context_to context
        items = keys.map do |key|
          cited_keys << key
          cited_keys.uniq!
          item = bibliography[key]
        end

        authors = items.map do |item|
          author = item.author[0].split(",")[0].gsub(/{|}/, '')
          if author.size > 1
            author << " et al."
          end
        end

        ct_id = generate_citation_tooltip(items)
        citation = citation_start(numeric=false, ct_id=ct_id)
        citation << authors.join(", ")
        citation << @@citation_end

#         p citation
        return citation
      end
    end
  end
end

Liquid::Template.register_tag('cite_author', Jekyll::Scholar::CiteAuthorTag)

puts "         >> Plugin: Jekyll scholar patch loaded"
