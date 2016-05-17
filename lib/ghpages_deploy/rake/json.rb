# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require 'json'
require 'set'

require 'ghpages_deploy/rake/task'

module GithubPages
  module JsonRakeExt
    class << self
      def directory_sitemap(files)
        directory_mash.tap { |root| files.each { |path| map_file(root, path) } }
      end

      def map_file(marker, path)
        *dirs, file = path.split('/')
        dirs.each { |dir| marker = marker[:dirs][dir] }
        marker[:files] << file
      end

      def sanitize_list(list)
        list.each_with_object(Set.new) { |glob, set| set.merge(Dir[glob]) }
      end

      def expand_lists(directory, whitelist, blacklist)
        Dir.chdir(directory) do
          lists = [whitelist, blacklist].map { |list| sanitize_list(list) }
          lists.reduce(&:-).select { |f| File.file?(f) }
        end
      end

      def directory_mash
        Hash[dirs: mash, files: []]
      end

      def mash
        Hash.new { |h, k| h[k] = directory_mash }
      end
    end

    def generate_json_sitemap(
      directory: '.', output: 'sitemap.json',
      whitelist: ['**/*'], blacklist: []
    )
      files = JsonRakeExt.expand_lists(directory, whitelist, blacklist)
      map = JsonRakeExt.directory_sitemap(files)

      File.open(output, 'w+') { |f| f.puts map.to_json }

      [output]
    end
  end

  DeployTask.include JsonRakeExt
end
