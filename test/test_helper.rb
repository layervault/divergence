require "test/unit"
require "rack"
require "rack/test"

require "./lib/divergence"

Test::Unit::TestCase.class_eval do
  include Rack::Test::Methods
end

class Test::Unit::TestCase
  def app
    Divergence::Application.new
  end

  # We have to rewrite the host constant in rack-test
  # in order to set a host with a subdomain. Gross.
  def set_request_addr(addr)
    old = $VERBOSE
    $VERBOSE = nil
    Rack::Test::DEFAULT_HOST.replace addr
    $VERBOSE = old
  end
end