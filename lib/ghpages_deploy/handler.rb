# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

module GithubPages
  class Handler
    def self.def_handler(sym)
      define_method(:"on_#{sym}") do |*args, &block|
        handlers[sym].map { |handle| handle.call(*args, &block) }
      end

      define_method(:"handle_#{sym}") do |&block|
        handlers[sym] << block
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
