module Divergence
  class RequestParser
    def initialize(env, git)
      @req = Rack::Request.new(env)
      @git = git
    end

    def raw
      @req
    end

    def host_parts
      @req.host.split(".")
    end

    def has_subdomain?
      host_parts.length > 2
    end

    def branch
      if has_subdomain?
        branch = host_parts.shift

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