require "test/unit"
require "rack"
require "rack/test"

require "./lib/divergence"

Test::Unit::TestCase.class_eval do
  include Rack::Test::Methods
end