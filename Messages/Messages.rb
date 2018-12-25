#!/usr/bin/env ruby -w
require "sqlite3"
require "fileutils"
require "tmpdir"
require "json"

module MessagesExporter
  
  class AppleMessages
    DEFAULT_MESSAGE_DIR = "~/Library/Messages"

    module Tools
      module_function
      def plutil(plist)
        out = IO.popen("plutil -convert json -o - -", mode="r+") do |io|
          io.write(plist)
          io.close_write
          io.read
        end
        JSON.parse out
      end
      def table_info(db, table_name)
        db.execute("PRAGMA table_info(#{table_name})").map do |x|
          x[1].to_sym
        end
      end
    end

    def initialize
      @chat = File.expand_path 'chat.db', DEFAULT_MESSAGE_DIR
      raise "no chat.db" unless File.exist? @chat
      @dir  = Dir.mktmpdir
      
      begin
        FileUtils.copy @chat, @dir
        # @type [SQLite3::Database]
        @db = SQLite3::Database.new File.expand_path('chat.db', @dir)
      rescue Exception => e
        deactivate
        raise e
      end
    end

    def deactivate
      FileUtils.remove_entry @dir
    end
    
    def self.eval(&block)
      instance = self.new
      begin
        instance.instance_exec(&block)
      ensure
        instance.deactivate
      end
    end

    private

    def sql_table_info_map(table_name)
      -> (x){ Hash[Tools.table_info(@db, table_name).zip x] }
    end

    def chat_session(cond=nil)
      result = @db.execute(<<-SQL).map(&sql_table_info_map("chat"))
        SELECT * FROM chat #{cond ? "WHERE (#{cond})" : ""}
      SQL
      result.map do |x|
        if x[:properties]
          x[:properties] = nil # Tools.plutil x[:properties]
        end
      end
      result
    end

    def message_session(chat, cond=nil)
      handleList = (chat.class == Array ? chat : [chat]).map do |one|
        chatID = case one
          when Hash then one[:ROWID]
          when String then one.to_i
          else one
        end
        find_handle = @db.execute(<<-SQL)
          SELECT handle_id FROM chat_handle_join WHERE chat_id=#{chatID}
        SQL
        handleID = find_handle.first
        raise "#{chatID} no handle join" unless handleID
        handleID = handleID.first.to_i
      end
      result = @db.execute(<<-SQL).map(&sql_table_info_map("message"))
        SELECT * FROM message WHERE (#{handleList.map{|x| "handle_id=#{x}"}.join(' OR ')}) #{cond ? "and (#{cond})" : ""}
        ORDER BY date
      SQL
      result
    end

    def attachment(mess)
      rowid = case mess
      when Hash
        if mess[:cache_has_attachments] == 0
          return nil
        else
          mess[:ROWID]
        end
      else mess
      end
      find_attachment = @db.execute(<<-SQL)
        SELECT attachment_id FROM message_attachment_join WHERE message_id=#{rowid}
      SQL
      attachmentID = find_attachment.first
      return nil unless attachmentID
      attachmentID = attachmentID.first.to_i
      result = @db.execute(<<-SQL).map(&sql_table_info_map("attachment"))
        SELECT * FROM attachment WHERE ROWID=#{attachmentID}
      SQL
      result.first
    end
  end

  class Telegram

  end
end

iMessagesExportTest = ->() {

MessagesExporter::AppleMessages.eval do
  puts @dir
  c = chat_session("
    chat_identifier='<phone number>' or
    chat_identifier='<email address>'")
  message_session(c).each do |x|
    print x[:is_from_me] == 1 ? "(*)" : "(-)"
    print x[:ROWID]
    print ' '
    if x[:cache_has_attachments] == 0
      puts x[:text]
    else
      a = attachment(x)
      if a
        e = File.exist? File.expand_path(a[:filename])
        puts "FILE: " + (e ? a[:filename] : 'lost')
      else
        puts "NOFILE"
      end
    end
    
  end
end

}