# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

module GithubPages
  class Handler
    def self.def_handler(sym)
      define_method(:"on_#{sym}") do |*args, &block|
        handlers[method].each { |handle| handle.call(*args, &block) }
        nil
      end

      define_method(:"handle_#{sym}") do |&block|
        handlers[method] << block
        nil
      end
    end

    def_handler :deploy

    private

    def handlers
      @handlers ||= Hash.new { |h, k| h[k] = [] }
    end
  end
end
