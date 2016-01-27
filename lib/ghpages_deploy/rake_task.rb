# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require 'rake'
require 'rake/tasklib'

require 'ghpages_deploy/deployer'
require 'ghpages_deploy/git_manager'

module GithubPages
  class DeployTask < ::Rake::TaskLib
    def initialize(name = :deploy)
      @name = name
      @destinations = []

      yield self if block_given?

      @source ||= '.'
      @remote ||= 'origin'

      @destinations << '.' if @destinations.empty?

      define
    end

    attr_accessor :name

    attr_accessor :remote, :source

    def register(destination)
      @destinations << destination
    end

    private

    def define
      task @name do
        GitManager.open(@remote) do |git|
          deployer = Deployer.new(git, @source, @destinations)
          deployer.deploy
        end
      end
    end
  end
end
