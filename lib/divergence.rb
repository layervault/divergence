require "rack/proxy"

require "divergence/version"
require "divergence/config"
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
