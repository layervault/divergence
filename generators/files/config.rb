require File.expand_path('../callbacks', __FILE__)

Divergence::Application.configure do |config|
  config.git_path = nil   # Change this to the git repository path
  config.app_path = nil   # and this to your application's path.
  config.cache_path = nil # This should be an empty directory

  # The number of branches to cache for quick switching. If you're
  # switching around between many branches frequently, you might
  # want to raise this. Keep in mind that each cached branch will
  # have it's own Passenger instance, so don't get too carried away.
  # config.cache_num = 5

  # Where should we proxy this request to? Normally you can leave
  # the host as 'localhost', but if you are using virtual hosts in
  # your web server setup, you may need to be more specific. You
  # will probably want Divergence to take over port 80 as well,
  # so update your web application to run on a different port.
  config.forward_host = 'localhost'
  config.forward_port = 80
end