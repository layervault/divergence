Divergence::Application.configure do |config|
  config.git_path = nil
  config.app_path = nil
  config.forward_host = 'localhost'
  config.forward_port = 80

  config.callbacks :after_swap do
    # Run anything after the swap finishes
  end
end