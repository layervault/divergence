require 'test_helper'

class ConfigureTest < Test::Unit::TestCase
  def test_config
    git_path = File.expand_path('../git_root', __FILE__)
    app_path = File.expand_path('../app_root', __FILE__)
    cache_path = File.expand_path('../cache_root', __FILE__)

    Divergence::Application.configure do |config|
      config.git_path = git_path
      config.app_path = app_path
      config.cache_path = cache_path

      config.forward_host = 'localhost'
      config.forward_port = 80
    end

    assert app.config.app_path, app_path
    assert app.config.git_path, git_path
    assert app.config.cache_path, cache_path
  end
end