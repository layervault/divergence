# Divergence

Map subdomains to git branches for switching live codebases on the fly. It's a Rack application that acts as a HTTP proxy between you and your web application for rapid testing.

## Installation

First, you will need to install the gem:

```
gem install divergence
```

Then, since divergence is a rackup application, you will need to initialize it somewhere by running:

```
divergence init
```

This copies all of the necessary files into the current folder for you.

### DNS

You have to do this manually for now. Hopefully in the future, Divergence will be able to automatically handle the DNS setup. All you need to do is create an A record with a wildcard subdomain that points to your testing server IP.

## Config

All configuration happens in `config/config.rb`. You must set the git repository root and the application root before using divergence.

You will probably want divergence to take over port 80 on your testing server, so you may have to update the forwarding host/port. Note, this is the address where your actual web application can be reached.

A sample config could look like this:

``` ruby
Divergence::Application.configure do |config|
  config.git_path = "/path/to/git_root"
  config.app_path = "/path/to/app_root"
  config.cache_path = "/path/to/cache_root"

  config.forward_host = 'localhost'
  config.forward_port = 80

  config.callbacks :after_swap do
    restart_passenger
  end

  config.callbacks :after_cache, :after_webhook do
    bundle_install :path => "vendor/bundle"
  end

  config.callbacks :on_branch_discover do |subdomain|
    case subdomain
    when "release-1"
      "test_branch"
    when "release-2"
      "other_branch"
    end
  end
end
```

### Callbacks

Divergence lets you hook into various callbacks throughout the entire process. These are defined in `config/callbacks.rb`. Most callbacks automatically change the current working directory for you in order to make modifications as simple as possible.

The available callbacks are:

* before_cache
  * Active dir: git repository
* after_cache
  * Active dir: cached folder path
* before_swap
  * Active dir: cached folder path
* after_swap
  * Active dir: application
* before_pull
  * Active dir: git repository
  * Only executes if a git pull is required
* after_pull
  * Active dir: git repository
  * Only executes if the git pull succeeds
* on_pull_error
  * Active dir: git repository
  * Executes if there is a problem checking out and pulling a branch
* on_branch_discover
  * Active dir: git repository
  * Executes if the subdomain has a dash in the name. The subdomain name is passed to the callback in the options hash.
  * If the callback returns nil, Divergence will try to auto-detect the branch name, otherwise it will use whatever you return.
* before_webook
  * Active dir: git repository
  * Runs before a branch is updated via webhooks.
* after_webhook
  * Active dir: cached folder path
  * Runs after a webhook update completes

There are also some built-in helper methods that are available inside callbacks. They are:

* bundle_install
  * Recommended - after_cache, after_webhook
  * Options:
    * :deployment => boolean
    * :path => string
* restart_passenger
  * Recommended - after_swap

### Github Service Hook

You can automatically keep the currently active branch up to date by using a Github service hook. In your repository on Github, go to Admin -> Service Hooks -> WebHook URLs. Add the url:

```
http://divergence.[your domain].com/update
```

Now, whenever you push code to your repository, divergence will automatically know and will update accordingly.

## Running

To start divergence, simply run in the divergence directory you initialized:

```
divergence start
```

This will start up divergence on port 9292 by default. If you'd like divergence to run on a different port, you can specify that as well:

```
divergence start --port=88
```

There is also a `--dev` flag that will run divergence in the foreground instead of daemonizing it.

### Port 80

On many systems, running on port 80 requires special permissions. If you try starting divergence, but get the error `TCPServer Error: Permission denied - bind(2)`, then you will need to run divergence with sudo (or as root). If you use RVM to manage multiple Ruby versions, then you can use `rvmsudo` instead.

Make sure, if you're using Git over SSH, that you have your repository's host added to your known hosts file for the root user.

### HTTPS

Divergence currently does not support HTTPS on its own; however, you can still use HTTPS in combination with a load balancer if you enable SSL termination.

### Invalid URL Characters

Git supports a much wider range of characters for branch names than URLs support. To get around this limitation, simply replace any invalid URL character with a `-` and Divergence will find the branch you're looking for automatically.

## TODO

* Handle simultaneous users better
* Built-in HTTPS support
* Helpers for more frameworks

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

* [Ryan LeFevre](http://meltingice.net) - Project Creator

## License

Licensed under the Apache 2.0 License. See LICENSE for details.
