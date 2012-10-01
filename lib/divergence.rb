require "rack/proxy"

require "divergence/version"
require "divergence/config"
require "divergence/webhook"

module Divergence
  class Application < Rack::Proxy
    @@config = Configuration.new

    def self.configure(&block)
      block.call(@@config)
    end

    def initialize
      unless File.exists?(config.path)
        raise "Configured path not found: #{config.path}"
      end
    end

    def config
      @@config
    end

    def call(env)
      @req = Rack::Request.new(env)

      # First, lets find out what subdomain/git branch
      # we're dealing with (if any).
      unless has_subdomain?
        # No subdomain, simply proxy the request.
        return perform_request(env)
      end

      perform_request(env)
    end

    def host_parts
      @req.host.split(".")
    end

    def has_subdomain?
      host_parts.length > 2
    end

    def branch
      if has_subdomain?
        host_parts.shift
      else
        nil
      end
    end
  end
end
