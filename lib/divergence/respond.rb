module Divergence
  class Application < Rack::Proxy
    # The main entry point for the application. This is caled
    # by Rack.
    def call(env)
      @req = RequestParser.new(env, @g)

      # Set the forwarding host always
      fix_environment!(env)

      # First, lets find out what subdomain/git branch
      # we're dealing with (if any).
      unless @req.has_subdomain?
        # No subdomain, simply proxy the request.
        return perform_request(env)
      end

      # Handle webhooks from Github for updating the current
      # branch if necessary.
      if @req.is_webhook?
        return Webhook.handle @g, @req
      end

      # Ask our GitManager to prepare the directory
      # for the given branch.
      result = @g.prepare_directory @req.branch
      if result === false
        return error!
      end

      # And then perform the codebase swap
      @g.swap!

      # Git is finished, pass the request through.
      status, header, body = perform_request(env)

      # This is super weird. Not sure why there is a status
      # header coming through, but Rack::Lint complains about
      # it, so we just remove it.
      if header.has_key?('Status')
        header.delete 'Status'
      end

      [status, header, body]
    end

    private

    # Sets the forwarding host for the request. This is where
    # the proxy comes in.
    def fix_environment!(env)
      env["HTTP_HOST"] = "#{config.forward_host}:#{config.forward_port}"
    end

    def error!
      Application.log.error "Branch #{@req.branch} does not exist"
      Application.log.error @req.raw

      public_path = File.expand_path('../../../public', __FILE__)
      file = File.open("#{public_path}/404.html", "r")
      contents = file.read
      file.close

      [404, {"Content-Type" => "text/html"}, [contents]]
    end
  end
end