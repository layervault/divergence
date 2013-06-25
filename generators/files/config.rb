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

  # Incoming base domain for requests, which will have a
  # branch name prepended to it
  config.incoming_base_uri = 'example.com'

  # Where should we proxy this request to? Normally you can leave
  # the host as 'localhost', but if you are using virtual hosts in
  # your web server setup, you may need to be more specific. You
  # will probably want Divergence to take over port 80 as well,
  # so update your web application to run on a different port.
  config.forward_host = 'localhost'
  config.forward_port = 80

  # If your site code is used for more than one virtual host, with
  # one being a subdomain of the other (e.g. example.com and
  # api.example.com) and both under the same git repository, you can supply
  # the additional domains in the config.site_subdomains array.
  # Note: if you use a config.forward_host value of 'localhost', then
  # Divergence will make the request to api.localhost, so you probably
  # want to use a different forward_host.
  # config.site_subdomains = ['api']
end
