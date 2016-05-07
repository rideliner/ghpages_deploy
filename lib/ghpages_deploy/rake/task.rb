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
      @handler = GithubPages::Handler.new

      yield self if block_given?

      @source &&= @source.gsub(%r{^#{Dir.pwd}[\/]?}, '')

      @destination ||= '.'
      @source ||= '.'
      @remote ||= 'origin'

      define
    end

    attr_accessor :remote, :source, :destination
    attr_accessor :repo, :branch
    attr_accessor :message
    attr_reader :handler

    private

    def define
      task(*@args) do
        GitManager.open(@remote, @source, @repo, @branch) do |git|
          Deployer.new(git, @source, @destination, @message, @handler).deploy
        end
      end
    end
  end
end
