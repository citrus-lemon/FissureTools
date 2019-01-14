#!/usr/bin/env ruby -w
require "sqlite3"
require "fileutils"
require "tmpdir"
module Photos

  class PhotosExporter

    # default photos library glob path
    DEFAULT_PHOTOS_LIB_DIR = "~/Pictures/*.photoslibrary"

    def initialize(path = nil, **opt)
      glob = Dir.glob(File.expand_path(path || DEFAULT_PHOTOS_LIB_DIR))
      if glob.count > 1
        raise ArgumentError, if path
          "cannot find only one photos library at #{path}"
        else
          "there are too many photos library"
        end
      elsif glob.count == 0
        raise ArgumentError, "cannot find #{path || DEFAULT_PHOTOS_LIB_DIR}"
      end
      @dir = glob.first
      @tmp = Dir.mktmpdir

      begin
        FileUtils.copy File.join(@dir, 'database', 'photos.db'), @tmp
        # @type [SQLite3::Database]
        @db = SQLite3::Database.new File.join(@tmp, 'photos.db')
      rescue Exception => e
        deactivate
        raise e
      end
    end

    def deactivate
      FileUtils.remove_entry @tmp
    end

    def self.eval(*args, **vargs, &block)
      instance = self.new(*args, **vargs)
      begin
        instance.instance_exec(&block)
      ensure
        instance.deactivate
      end
    end

  end

  module_function

  def test
    puts "test"
    a = PhotosExporter.new
    require "pp"
    pp a
  end

end

Photos::test if __FILE__ == $0