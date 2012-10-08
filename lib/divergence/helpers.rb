require 'fileutils'

module Divergence
  class Helpers
    def initialize(config)
      @config = config
    end

    def execute(block)
      self.instance_eval &block
    end

    private

    def bundle_install
      Application.log.debug "bundle install"
      
      Dir.chdir @config.app_path do
        `bundle install`
      end
    end

    def restart_passenger
      Application.log.debug "Restarting passenger..."

      Dir.chdir @config.app_path do
        FileUtils.touch 'tmp/restart.txt'
      end
    end
  end
end