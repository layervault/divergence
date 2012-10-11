module Divergence
  class Application < Rack::Proxy
    # The main entry point for the application. This is caled
    # by Rack.
    def call(env)
      @req = RequestParser.new(env)

      # First, lets find out what subdomain/git branch
      # we're dealing with (if any).
      unless @req.has_subdomain?
        # No subdomain, simply proxy the request.
        return proxy(env)
      end

      # Handle webhooks from Github for updating the current
      # branch if necessary.
      if @req.is_webhook?
        return Webhook.handle @g, @req
      end

      # Ask our GitManager to prepare the directory
      # for the given branch.
      begin
        branch = @git.discover(@req.subdomain)
        path = prepare(branch)
        swap!(path) unless path.nil?
      rescue
        return error!
      end

      # We're finished, pass the request through.
      proxy(env)
    end

    private

    def proxy(env)
      fix_environment!(env)
      
      status, header, body = perform_request(env)

      # This is super weird. Not sure why there is a status
      # header coming through, but Rack::Lint complains about
      # it, so we just remove it. I think this might be coming
      # from Cloudfront (if you use it).
      if header.has_key?('Status')
        header.delete 'Status'
      end

      [status, header, body]
    end

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