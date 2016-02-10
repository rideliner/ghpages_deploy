# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

require 'ghpages_deploy/rake/task'

module GithubPages
  module JekyllRakeExt
    def init_jekyll
      @handler.handle_deploy do
        FileUtils.touch('.nojekyll') unless File.exist?('.nojekyll')
        ['.nojekyll']
      end
    end
  end

  DeployTask.include JekyllRakeExt
end
