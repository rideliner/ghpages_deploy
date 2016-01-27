# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require 'zlib'

require 'ghpages_deploy/util'

module GithubPages
  class SiteCompressor
    def initialize(directory)
      @directory = directory
      @level = Zlib::BEST_COMPRESSION
    end

    attr_accessor :level

    def compress
      GithubPages.all_nested_files(@directory).each do |item|
        compress_file(item) if can_compress?(item) && !compressed?(item)
      end
    end

    private

    def compress_file(filename)
      Zlib::GzipWriter.open("#{filename}.gz", @level) do |gz|
        gz.mtime = File.mtime(filename)
        gz.orig_name = filename
        gz.write File.binread(filename)
      end
      File.rename("#{filename}.gz", filename)
    end

    def can_compress?(filename)
      ext = File.extname(filename)
      return false if ext.empty?
      %i(css js html).include?(ext[1..-1].to_sym)
    end

    GZIP_MAGIC = ['1F8B'].pack('H*')

    def compressed?(filename)
      File.open(filename) do |f|
        f.readpartial(2) == GZIP_MAGIC
      end
    rescue EOFError
      false
    end
  end
end
