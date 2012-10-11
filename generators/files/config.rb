require File.expand_path('../callbacks', __FILE__)

Divergence::Application.configure do |config|
  config.git_path = nil # Change this to the git repository path
  config.app_path = nil # and this to your application's path.

  # Where should we proxy this request to? Normally you can leave
  # the host as 'localhost', but if you are using virtual hosts in
  # your web server setup, you may need to be more specific. You
  # will probably want Divergence to take over port 80 as well,
  # so update your web application to run on a different port.
  config.forward_host = 'localhost'
  config.forward_port = 80
end