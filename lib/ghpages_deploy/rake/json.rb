# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require 'json'

require 'ghpages_deploy/rake/task'

module GithubPages
  module JsonRakeExt
    # designed for a documentation sitemap
    # best used with a format similar to the following:
    #
    # tag/
    #   v1.0.0/
    #     _index.html
    #     ...
    #   v1.1.0/
    #     index.html
    #     _index.html
    #     ...
    #   ...
    # branch/
    #   master/
    #     index.html
    #     ...
    #   ...
    #

    # if update_sitemap is being called, excluded directories should be relative to './'

    def self.update_sitemap(excluded)
      mapping = directory_sitemap('.', excluded).last

      File.open('sitemap.json', 'w+') do |file|
        file.write mapping.to_json
      end
    end

    def self.directory_sitemap(dir, excluded)
      mapping =
        Dir.foreach(dir).flat_map do |file|
          file_dir = File.join(dir, file)
          next [] if excluded.include?(file_dir)
          next [] if %w(.git . ..).include?(file)
          next [] unless Dir.exist?(file_dir)

          index =
            %w(index.html _index.html).find do |html|
              File.exist?(File.join(file_dir, html))
            end

          next [File.basename(file_dir), index] if index

          map = directory_sitemap(file_dir, excluded)
          next [] if !map || map.empty?
          map
        end

      return nil if mapping.empty?
      [File.basename(dir), Hash[*mapping]]
    end

    def json_sitemap(excluded = [])
      handler.handle_deploy do
        JsonRakeExt.update_sitemap(excluded)
        ['sitemap.json']
      end
    end
  end

  DeployTask.include JsonRakeExt
end
