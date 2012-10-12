module Divergence
  class RequestParser
    def initialize(env)
      @req = Rack::Request.new(env)
    end

    def raw
      @req
    end

    def is_webhook?
      subdomain == "divergence" and 
      @req.env['PATH_INFO'] == "/update" and
      @req.post?
    end

    def host_parts
      @req.host.split(".")
    end

    def has_subdomain?
      host_parts.length > 2
    end

    def subdomain
      if has_subdomain?
        host_parts.shift
      else
        nil
      end
    end

    def branch
      if has_subdomain?
        branch = subdomain

        if branch['-']
          @git.discover(branch)
        else
          branch
        end
      else
        nil
      end
    end

    def method_missing(meth, *args, &block)
      raw.send(meth, *args)
    end
  end
end