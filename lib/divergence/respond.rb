module Divergence
  class Application < Rack::Proxy
    def call(env)
      @req = RequestParser.new(env)

      if is_webhook?
        return handle_webhook
      end

      # First, lets find out what subdomain/git branch
      # we're dealing with (if any).
      unless @req.has_subdomain?
        # No subdomain, simply proxy the request.
        return perform_request(env)
      end

      # Ask our GitManager to prepare the directory
      # for the given branch.
      @g.prepare_directory @req.branch

      # And then perform the codebase swap
      @g.swap!
      
      # Git is finished, pass the request through.
      perform_request(env)
    end
  end
end