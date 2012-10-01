module Divergence
  class Application < Rack::Proxy
    def is_webhook?
      @req.path_info == "/divergence-webhook" && @req.post?
    end
  end
end