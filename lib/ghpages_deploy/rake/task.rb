# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require 'rake'
require 'rake/tasklib'

require 'ghpages_deploy/deployer'
require 'ghpages_deploy/git_manager'
require 'ghpages_deploy/handler'

module GithubPages
  class DeployTask < ::Rake::TaskLib
    def initialize(*args)
      @args = args
      @destinations = []

      yield self if block_given?

      @source ||= '.'
      @remote ||= 'origin'

      @destinations << '.' if @destinations.empty?

      @handler = GithubPages::Handler.new
    end

    attr_accessor :remote, :source
    attr_reader :handler

    def register(destination)
      @destinations << destination
    end

    private

    def define
      task(*@args) do
        GitManager.open(@remote) do |git|
          deployer = Deployer.new(git, @source, @destinations)
          deployer.deploy(@handler)
        end
      end
    end
  end
end
