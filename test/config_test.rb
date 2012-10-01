require 'test_helper'

class ConfigureTest < Test::Unit::TestCase
  def test_config
    path = File.expand_path('../root', __FILE__)
    Divergence::Application.configure do |config|
      config.path = path
    end

    assert app.config.path, path
  end
end