require "divergence/version"
require "divergence/config"

module Divergence
  class Application
    def config
      @@config
    end
    
    def call(env)
      req = Rack::Request.new(env)

      # First, lets find out what subdomain/git branch
      # we're dealing with (if any).
      puts req.host
    end
  end
end
