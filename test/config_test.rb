require 'test_helper'

class ConfigureTest < Test::Unit::TestCase
  def test_config
    Divergence::Application.configure do |config|
      config.path = "/foo"
    end

    assert app.config.path, "/foo"
  end
end