require "rack/proxy"
require "git"
require "json"
require "logger"

require "divergence/version"
require "divergence/config"
require "divergence/git_manager"
require "divergence/helpers"
require "divergence/request_parser"
require "divergence/respond"
require "divergence/webhook"

module Divergence
  class Application < Rack::Proxy
    @@config = Configuration.new
    @@log = Logger.new('./log/app.log')

    def self.configure(&block)
      block.call(@@config)
    end

    def self.log
      @@log
    end

    def self.config
      @@config
    end

    def initialize
      file_checks

      @g = GitManager.new(config)
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
