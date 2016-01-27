# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

module GithubPages
  def all_nested_files(dir)
    files = Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH)
    files.delete_if { |file| file =~ %r{(^|/)?\.?\.$} }
  end
  module_function :all_nested_files
end
