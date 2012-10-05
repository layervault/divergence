require 'test_helper'

class ConfigureTest < Test::Unit::TestCase
  def test_config
    git_path = File.expand_path('../git_root', __FILE__)
    app_path = File.expand_path('../app_root', __FILE__)

    Divergence::Application.configure do |config|
      config.git_path = git_path
      config.app_path = app_path
      config.forward_host = 'localhost'
      config.forward_port = 80

      config.callbacks :after_swap do
      end
    end

    assert app.config.app_path, app_path
    assert app.config.git_path, git_path
  end
end