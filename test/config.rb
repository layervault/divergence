Divergence::Application.configure do |config|
  config.git_path = "test/git_root"
  config.app_path = "test/app_root"
  config.forward_host = 'localhost'
  config.forward_port = 80

  config.callbacks :after_swap do
    # Run anything after the swap finishes
  end
end