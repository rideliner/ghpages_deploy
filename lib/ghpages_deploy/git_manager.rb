# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require 'git'
require 'logger'

module GithubPages
  class GitManager
    def initialize(remote, preserved_dir)
      @preserved = preserved_dir
      @remote = remote
      @repo = `git config remote.#{remote}.url`.gsub(/^git:/, 'https:')
      @branch =
        if @repo =~ /\.github\.(?:com|io)\.git$/
          'master'
        else
          'gh-pages'
        end

      @git = Git.open(Dir.pwd)

      setup
    end

    def self.open(remote)
      git = new(remote)
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
      @git.push(remote, branch)
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
      @git.add_remote(remote, repo) unless @git.remote(remote)
      @git.config("remote.#{remote}.fetch", "+refs/heads/*:refs/remotes/#{remote}/*")
      @git.remote(remote).fetch
    end

    def setup_user
      @git.config('user.name', ENV['GIT_NAME']) if ENV['GIT_NAME']
      @git.config('user.email', ENV['GIT_EMAIL']) if ENV['GIT_EMAIL']
    end

    def remove_staged
      to_remove = staged_modifications('.')
      @git.remove(to_remove) unless to_remove.empty?

      git "clean -d -x --exclude #{@preserved}/"
    end

    def setup_branch
      if @git.is_local_branch?(branch)
        @git.branch(branch).checkout
        remove_staged
      elsif @git.is_remote_branch?(branch)
        git "checkout #{remote}/#{branch} -b #{branch}"
        remove_staged
        @git.pull(remote, branch)
      else
        git "checkout --orphan #{branch}"
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
