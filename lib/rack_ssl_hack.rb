# Monkey patching sucks, but Rack seems to think we have
# HTTPS even with SSL termination enabled. This force
# disables it until HTTPS is built-in to divergence.
module Rack
  class HttpStreamingResponse
    def use_ssl
      false
    end

    def use_ssl=(v)
      self.instance_variable_set(:@use_ssl, false)
    end
  end
end