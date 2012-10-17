require "rack/proxy"
require "json"
require "logger"
require "fileutils"

require "rack_ssl_hack"
require "divergence/version"
require "divergence/config"
require "divergence/application"
require "divergence/git_manager"
require "divergence/cache_manager"
require "divergence/helpers"
require "divergence/request_parser"
require "divergence/respond"
require "divergence/webhook"

module Divergence
  class Application < Rack::Proxy
    @@config = Configuration.new
    @@log = Logger.new('./log/app.log')

    def self.configure(&block)
      block.call(@@config)
    end

    def self.log
      @@log
    end

    def self.config
      @@config
    end

    def initialize
      config.ok?

      @git = GitManager.new(config.git_path)
      @cache = CacheManager.new(config.cache_path, config.cache_num)
      @active_branch = ""
    end

    def config
      @@config
    end
  end
end
