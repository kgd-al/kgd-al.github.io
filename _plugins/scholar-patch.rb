module Jekyll
  class Scholar
    module Utilities
      alias_method :old_citation, :render_citation

      @@sep=","
      @@r_sep="-"

      def citation_start(numeric)
          span = "<span class=\"citation-span"
          if numeric
            span << " citation-numeric"
          end
          span << "\">"
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

      def render_citation_tooltip(items)
          tooltip = ""
          tooltip << "<sup class=\"citation-tooltip\" markdown=\"span\">"
          tooltip << "<span class=\"citation-tooltip-content bibliography\">"
          tooltip << items.map {|item| "<bi>[#{citation_number(item.key)}] #{reference_tag(item)}</bi>"}.join("<br/>")
          tooltip << "</span>"
          tooltip << "</sup>"
          return tooltip
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

        id_to_key = Hash[keys.map{|k| [citation_number(k), k]}]

        hrefs = []
        items_id.each do |id|
            sub_hrefs = []
            id.split(@@r_sep).each do |sid|
                key = id_to_key[sid.to_i]
                sub_hrefs.append(link_to(link_target_for(key), sid, cite_attributes))
            end
            hrefs.append(sub_hrefs.join(@@r_sep))
        end

        citation = citation_start(numeric=true)
        citation << hrefs.join(@@sep)
        citation << render_citation_tooltip(items)
        citation << @@citation_end

#         p citation
        return citation
      end

      alias_method :old_render_bibliography, :render_bibliography
      def render_bibliography(entry, index = nil)
        # Remove numerical part
        bib_item = old_render_bibliography(entry, index)
        if context.registers[:site].config['scholar']['type'] == "numeric"
            bib_item = bib_item.sub! /\A.*?(?=[A-Z])/mi, ''
        end
        return bib_item
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
          link_to(link_target_for(item.key), author, cite_attributes)
        end

        citation = citation_start(numeric=false)
        citation << authors.join(", ")
        citation << render_citation_tooltip(items)
        citation << @@citation_end

#         p citation
        return citation
      end
    end
  end
end

Liquid::Template.register_tag('cite_author', Jekyll::Scholar::CiteAuthorTag)

puts "          >> Plugin: Jekyll scholar patch loaded"
