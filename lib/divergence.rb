require "rack/proxy"
require "git"
require "logger"

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

      @g = GitManager.new(config.git_path, config.app_path)
    end

    def config
      @@config
    end

    private

    def file_checks
      unless File.exists?(config.app_path)
        raise "Configured path not found: #{config.app_path}"
      end

      unless File.exists?(config.git_path)
        raise "Configured git path not found: #{config.git_path}"
      end
    end
  end
end
