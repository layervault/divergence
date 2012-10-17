module Divergence
  class Application < Rack::Proxy
    # The main entry point for the application. This is called
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
        return handle_webhook
      end

      # Lets get down to business.
      begin
        # Get the proper branch name using a touch of magic
        branch = @git.discover(@req.subdomain)

        # Prepare the branch and cache if needed
        path = prepare(branch)
        
        # If we're requesting a different branch than the
        # one currently loaded, we'll need to link it to
        # the application directory.
        link!(path) unless path.nil?
        
        @active_branch = branch
      rescue Exception => e
        Application.log.error e.message
        return error!(branch)
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

    def error!(branch)
      Application.log.error "Branch #{branch} does not exist"
      Application.log.error @req.raw

      public_path = File.expand_path('../../../public', __FILE__)
      file = File.open("#{public_path}/404.html", "r")
      contents = file.read
      file.close

      [404, {"Content-Type" => "text/html"}, [contents]]
    end
  end
end