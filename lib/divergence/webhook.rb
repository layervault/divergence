module Divergence
  class Application < Rack::Proxy
    def is_webhook?
      @req.path_info == "/divergence-webhook" && @req.post?
    end

    def handle_webhook
      [200, {"Content-Type" => "text/html"}, [""]]
    end
  end
end