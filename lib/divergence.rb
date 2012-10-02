require "rack/proxy"
require "git"

require "divergence/version"
require "divergence/config"
require "divergence/git_manager"
require "divergence/request_parser"
require "divergence/respond"
require "divergence/webhook"

module Divergence
  class Application < Rack::Proxy
    @@config = Configuration.new

    def self.configure(&block)
      block.call(@@config)
    end

    def initialize
      file_checks

      @g = GitManager.new(config.path)
    end

    def config
      @@config
    end

    private

    def file_checks
      unless File.exists?(config.path)
        raise "Configured path not found: #{config.path}"
      end

      unless File.exists?(config.path + "/.git")
        raise "Configured path is not a Git repository: #{config.path}"
      end
    end
  end
end
