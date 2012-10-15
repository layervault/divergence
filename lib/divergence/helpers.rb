require 'fileutils'

module Divergence
  class Helpers
    def initialize(config)
      @config = config
    end

    def execute(block, opts={})
      self.instance_exec opts, &block
    end

    private

    def bundle_install
      Application.log.debug "bundle install"

      Dir.chdir @config.app_path do
        `bundle install --deployment`
      end
    end

    def restart_passenger
      Application.log.debug "Restarting passenger..."

      Dir.chdir @config.app_path do
        begin
          FileUtils.touch 'tmp/restart.txt'
        rescue
        end
      end
    end
  end
end