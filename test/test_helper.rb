require "test/unit"
require "rack"
require "rack/test"

require "./lib/divergence"
require "./test/config"

#require 'debugger'; debugger

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

  def active_branch
    file = File.open 'test/app_root/test.txt'
    contents = file.read.strip
    file.close
    contents
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

  def mock_get(addr, params={})
    env = Rack::MockRequest.env_for "http://#{addr}",
      :params => params

    app.call env
  end

  def mock_post(addr, params={})
    env = Rack::MockRequest.env_for "http://#{addr}",
      :method => :post,
      :params => params

    app.call env
  end

  def mock_webhook(branch)
    mock_post "divergence.example.com/update",
      :payload => JSON.generate({
        :ref => "refs/heads/#{branch.to_s}"
        })
  end
end

module Divergence
  class Application < Rack::Proxy
    attr_accessor :req, :active_branch

    def perform_request(env)
      [200, {"Content-Type" => "text/html"}, ["Ohai"]]
    end
  end
end