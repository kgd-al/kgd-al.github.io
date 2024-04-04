puts "custom plugin root"
module Jekyll
  class Scholar
    module Utilities
      alias_method :old_citation, :render_citation

      def format_range(group)
        case group.size
        when 1
            "#{group[0]}"
        when 2
            group.join(", ")
        else
            "#{group[0]}-#{group[-1]}"
        end
      end

      def items_in_citation(citation)
        begin_span_end = citation.index('>')
        end_span_start = citation.index('<', begin_span_end)
        items_id = citation[begin_span_end+1..end_span_start-1].split(", ")
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

            items_merged = items_groups.map{|g| format_range(g)}.join(", ")
            citation = citation[0..begin_span_end] + items_merged + citation[end_span_start..-1]
        end
        citation
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

        attributes = {class: config['cite_class']}
        if keys.size == 1
            link_to link_target_for(keys[0]), render_citation(items), attributes
        else
            citation = render_citation(items)

            begin_span_end, end_span_start, items_id = items_in_citation(citation)
            new_citation = citation[..begin_span_end]

            id_to_key = Hash[keys.map{|k| [citation_number(k), k]}]

            hrefs = []
            items_id.each do |id|
                sub_hrefs = []
                id.split("-").each do |sid|
                    key = id_to_key[sid.to_i]
                    sub_hrefs.append(link_to(link_target_for(key), sid, attributes))
                end
                hrefs.append(sub_hrefs.join("-"))
            end

            new_citation << hrefs.join(", ")
            new_citation << citation[end_span_start..]
            return new_citation
        end
      end
    end
  end
end
# Liquid::Template.register_tag('amazon', Jekyll::Amazon::AmazonTag)
