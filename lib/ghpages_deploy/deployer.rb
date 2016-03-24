# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require 'ghpages_deploy/compress'
require 'ghpages_deploy/git_manager'

module GithubPages
  class Deployer
    def initialize(git, source, destinations, handler)
      @git = git
      @source = source
      @destinations = destinations
      @handler = handler
    end

    def deploy
      @destinations.keep_if { |dest| deploy_site_to(dest) }

      @git.stage @handler.on_deploy.flatten.uniq if @handler

      if @git.staged_modifications('.').empty?
        $stderr.puts 'No changes detected, not commiting.'
      else
        @git.commit_and_push message
      end
    end

    # remove files that are already cached in the destination directory
    # or have return false when passed to {Handler#precheck_delete?}
    def clean_destination(dest)
      cached = @git.ls_files(dest)

      if @handler
        cached.select! do |file|
          results = @handler.on_precheck_delete?(file)
          # a file gets removed if there are no results or any result is false
          results.empty? || results.inject(&:&)
        end
      end

      @git.remove(*cached)
    end

    private

    # @return [Boolean] true if there were changes to the destination
    def deploy_site_to(dest)
      clean_destination(dest)

      # create the full path to the destination
      FileUtils.mkdir_p(dest)

      # recursively copy all files from @source into dest
      FileUtils.cp_r("#{@source}/.", dest)

      stage_destination_files(dest)

      # check if any changes were made to the destination
      !@git.staged_modifications(dest).empty?
    end

    def stage_destination_files(dest)
      files = GithubPages.all_nested_files(@source)
      files.keep_if { |file| File.file?(file) }

      files.map! do |file|
        simple = file.sub(%r{^#{@source}/?}, '')
        File.join(dest, simple)
      end

      @git.stage files
    end

    def message
      return 'Handler updates' if @destinations.empty?

      # English join
      msg =
        if @destinations.length == 1
          @destinations.first
        elsif @destinations.length == 2
          @destinations.join ' and '
        else
          @destinations[0..-2].join(', ') + ", and #{@destinations.last}"
        end

      "Deployed to #{msg}."
    end
  end
end
