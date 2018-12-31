#!/usr/bin/env ruby -w
require_relative 'DCSDictionary/binding'
module DictionaryServices
  
  module Parser
    private
    begin
      require 'nokogiri'
    rescue LoadError
      def parse(html)
        raise NotImplementedError, 'You need install nokogiri'
      end
    else
      def _parse_head(el)
        {
          :text => el.css('> span.hw').children.select{|a| a.is_a? Nokogiri::XML::Text}.map(&:text).join
        }
      end
      def _parse_sections(el)
        el.css('> span.x_xd0').map do |e|
          e.css('> .x_xdh .tg_pos').text.strip
        end
      end
      def _parse_other(el)
        {}
      end
      def _parse(html)
        # html = html.gsub(/<span(\w)/) {"<span #{$1}"}
        dic = Nokogiri::HTML.parse(html)
        entrys = dic.xpath('/html/body/entry')
        entrys.map do |en|
          head = nil
          sections = nil
          other = []
          en.children.each do |o|
            if o.is_a?(Nokogiri::XML::Element) and o.name == 'span'
              if o.classes.include? "hg"
                raise "multi head `hg` element" if head
                head = _parse_head(o)
              elsif o.classes.include? "sg"
                sections = _parse_sections(o)
              elsif o.classes.include? "x_xo0"
                other.push _parse_other(o)
              end
            else
              puts "no span #{o}"
            end
          end
          {:head => head, :sections => sections, :other => other}
        end
      end
    end
  end

  class DCSDictionary
    def search(text, mode = 0, max_records = 100)
      records_for_search_string(text, mode, max_records)
    end
  end

  class DCSRecord
    include Parser
    def get
      _parse self.data
    end
  end
  
end