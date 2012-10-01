module Divergence
  class Application < Rack::Proxy
    def call(env)
      req = RequestParser.new(env)

      # First, lets find out what subdomain/git branch
      # we're dealing with (if any).
      unless req.has_subdomain?
        # No subdomain, simply proxy the request.
        return perform_request(env)
      end

      perform_request(env)
    end
  end
end