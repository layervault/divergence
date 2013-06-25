module Divergence
  class RequestParser

    attr_accessor :called_site_subdomain

    def initialize(env, config)
      @req = Rack::Request.new(env)
      @config = config

      @host_parts = @req.host.split(".")
      @called_site_subdomain = nil
    end

    def raw
      @req
    end

    def is_webhook?
      @host_parts[0] == "divergence" and
      @req.env['PATH_INFO'] == "/update" and
      @req.post?
    end

    def has_subdomain?
      @host_parts.length > @config.incoming_base_uri_length
    end

    def branch
      if has_subdomain?
        branch = @host_parts[0]

        if @config.site_subdomains.include?(branch)
          @called_site_subdomain = branch
          branch = @host_parts[1]
        end
        branch
      else
        nil
      end
    end

    def method_missing(meth, *args, &block)
      raw.send(meth, *args)
    end
  end
end
