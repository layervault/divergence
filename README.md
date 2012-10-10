# Divergence

Divergence is a Rack application that acts as a HTTP proxy between you and your web application. It maps subdomains to git branches for switching live codebases on the fly. Divergence is primarily designed for application testing purposes.

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

If you are using rackup for your actual web application, you will want to add one line to your config.ru:

``` ruby
use Rack::Reloader unless ENV['RACK_ENV'] == 'production'
```

This prevents issues when switching the entire codebase around.

## Config

All configuration happens in `config/config.rb`. You must set the git repository root and the application root before using Divergence.

You will probably want Divergence to take over port 80 on your testing server, so you may have to update the forwarding host/port. Note, this is the address where your actual web application can be reached.

### Callbacks

Divergence lets you hook into various callbacks throughout the entire process. These are defined in `config/callbacks.rb`. Most callbacks automatically change the current working directory for you in order to make modifications as simple as possible.

The available callbacks are:

* before_swap
  * Active dir: git repository
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

There are also some built-in helper methods that are available inside callbacks. They are:

* bundle_install
* restart_passenger

## Running

To start divergence, simply run in the divergence directory you initialized:

```
divergence start
```

This will start up divergence on port 9292 by default. If you'd like divergence to run on a different port, you can specify that as well:

```
divergence start --port=88
```

### Port 80

On many systems, running on port 80 requires special permissions. If you try starting divergence, but get the error `TCPServer Error: Permission denied - bind(2)`, then you will need to run divergence with sudo (or as root). If you use RVM to manage multiple Ruby versions, then you can use `rvmsudo` instead.

Make sure, if you're using Git over SSH, that you have your repository's host added to your known hosts file for the root user.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

* [Ryan LeFevre](http://meltingice.net) - Project Creator
