# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require 'ghpages_deploy/compress'
require 'ghpages_deploy/git_manager'

module GithubPages
  class Deployer
    def initialize(git, source, destinations)
      @git = git
      @source = source
      @destinations = destinations
    end

    def deploy
      SiteCompressor.new(@source).compress

      # remove files that are already staged as a result of switching branches
      @git.staged_modifications('.').each { |file| File.delete(file) }

      @destinations.keep_if { |dest| deploy_site_to(dest) }

      if @destinations.empty?
        $stderr.puts 'No changes detected, not commiting.'
      else
        @git.commit_and_push message
      end
    end

    private

    # @return [Boolean] true if there were changes to the destination
    def deploy_site_to(dest)
      # create the full path to the destination
      FileUtils.mkdir_p(dest)

      # remove files that are already cached in the destination directory
      @git.ls_files(dest).each { |file| File.delete(file) }

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
