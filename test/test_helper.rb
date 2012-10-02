require "test/unit"
require "rack"
require "rack/test"

require "./lib/divergence"

Test::Unit::TestCase.class_eval do
  include Rack::Test::Methods
end

class Test::Unit::TestCase
  def app
    unless @d
      @d = Divergence::Application.new
    end

    @d
  end

  # We have to rewrite the host constant in rack-test
  # in order to set a host with a subdomain. Gross.
  def set_request_addr(addr)
    old = $VERBOSE
    $VERBOSE = nil
    Rack::Test::DEFAULT_HOST.replace addr
    $VERBOSE = old
  end

  def set_mock_request(addr, opts={})
    req = Rack::MockRequest.env_for "http://#{addr}", opts

    app.req = Divergence::RequestParser.new(req)
  end

  def mock_get(addr)
    env = Rack::MockRequest.env_for "http://#{addr}"
    app.call env
  end
end

module Divergence
  class Application < Rack::Proxy
    attr_accessor :req

    def perform_request(env)
      [200, {"Content-Type" => "text/html"}, ["Ohai"]]
    end
  end
end