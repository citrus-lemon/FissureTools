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
      def parse(html)
        html = html.gsub(/<span(\w)/) {"<span #{$1}"}
        # Nokogiri::HTML.parse(html)
        html
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
      parse self.data
    end
  end
  
end