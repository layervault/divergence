# Divergence

Divergence is a Rack application that acts as a HTTP proxy between your web server and your web application. It uses virtual hosts to switch live codebases on the fly by mapping subdomains to git branches. Divergence is primarily for application testing purposes.

## Installation

First, you will need to install the gem:

```
gem install divergence
```

Then, since divergence is a rackup application, you will need to initialize it somewhere by running:

```
divergence init [FOLDER]
```

This creates the given folder and will copy all of the necessary files for you.

If you are using rackup for your web application, you will need to add one line to your config.ru:

```
use Rack::Reloader unless ENV['RACK_ENV'] == 'production'
```

This prevents issues when switching the entire codebase around.

## Config

TODO

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
