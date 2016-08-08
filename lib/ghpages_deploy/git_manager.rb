# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require 'git'
require 'logger'

module GithubPages
  class GitManager
    def initialize(remote, preserved_dir, repo = nil, branch = nil)
      @preserved = preserved_dir
      @remote = remote
      @repo = repo || `git config remote.#{remote}.url`.gsub(/^git:/, 'https:')
      @branch = branch || default_branch

      @git = Git.open(Dir.pwd)

      setup
    end

    def default_branch
      if @repo =~ /\.github\.(?:com|io)\.git$/
        'master'
      else
        'gh-pages'
      end
    end

    def self.open(*args, &block)
      git = new(*args, &block)
      yield git
      git.cleanup
    end

    def cleanup
      cleanup_credentials
    end

    def stage(files)
      @git.add files unless files.empty?
    end

    def staged_modifications(dir)
      cached_files('diff --name-only', dir)
    end

    def ls_files(dir)
      cached_files('ls-files', dir)
    end

    def commit_and_push(msg)
      @git.commit(msg)
      @git.push(remote, "ghpages_deployment:#{branch}")
    end

    def remove(*files)
      @git.remove(files) unless files.empty?
    end

    private

    attr_reader :remote, :branch, :repo

    def cached_files(cmd, dir)
      git("#{cmd} --cached -z #{dir}").split("\0")
    end

    CREDENTIALS_FILE = '.git/credentials'.freeze

    def git(command)
      `git #{command}`
    end

    def setup
      setup_repo
      setup_user
      setup_credentials
      setup_branch
    end

    def setup_repo
      @git.remove_remote(remote) if @git.remotes.map(&:name).include?(remote)
      @git.add_remote(remote, repo)
      @git.remote(remote).fetch
    end

    def setup_user
      @git.config('user.name', ENV['GIT_NAME']) if ENV['GIT_NAME']
      @git.config('user.email', ENV['GIT_EMAIL']) if ENV['GIT_EMAIL']
    end

    def remove_staged
      remove(*staged_modifications('.'))

      git "clean -d -x -f -e #{@preserved}"
    end

    def remote_branch?
      @git.branches.remote.any? do |br|
        br.name == branch && br.remote.name == remote
      end
    end

    def setup_branch
      if remote_branch?
        puts 'checking out remote branch'
        git "checkout -b ghpages_deployment #{remote}/#{branch}"
        remove_staged
        @git.pull(remote, branch)
      else
        puts 'checking out orphan branch'
        git "checkout --orphan ghpages_deployment"
        remove_staged
      end
    end

    def setup_credentials
      @git.config('credential.helper', "store --file=#{CREDENTIALS_FILE}")
      File.open(CREDENTIALS_FILE, 'w') do |file|
        token = ENV['GITHUB_OAUTH_TOKEN']
        file.write "https://#{token}:x-oauth-basic@github.com"
      end
    end

    def cleanup_credentials
      # TODO
    end
  end
end
