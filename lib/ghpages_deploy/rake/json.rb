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

    def self.update_sitemap
      File.open('sitemap.json', 'w+') do |file|
        file.write directory_sitemap('.').to_json
      end
    end

    def self.directory_sitemap(dir)
      index =
        %w(index.html _index.html).find do |html|
          File.exist?(File.join(dir, html))
        end

      return {File.basename(dir) => index} if index

      Hash[Dir.foreach(dir).flat_map do |file|
        file_dir = File.join(dir, file)
        next [] if %w(.git . ..).include?(file)
        next [] unless Dir.exist?(file_dir)

        map = directory_sitemap(file_dir)
        next [] if map.empty?
        [file, map]
      end]
    end

    def json_sitemap
      handler.handle_deploy do
        JsonRakeExt.update_sitemap
        ['sitemap.json']
      end
    end
  end

  DeployTask.include JsonRakeExt
end
