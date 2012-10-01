require "rack/proxy"

require "divergence/version"
require "divergence/config"

module Divergence
  class Application < Rack::Proxy
    @@config = Configuration.new

    def self.configure(&block)
      block.call(@@config)
    end

    def config
      @@config
    end

    def call(env)
      @req = Rack::Request.new(env)

      # First, lets find out what subdomain/git branch
      # we're dealing with (if any).
      if @req.host.split(".").size < 3
        # No subdomain, simply proxy the request.
        return perform_request(env)
      end

      perform_request(env)
    end
  end
end
