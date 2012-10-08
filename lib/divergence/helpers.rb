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

    def restart_passenger
      Dir.chdir @config.app_dir do
        FileUtils.touch 'tmp/restart.txt'
      end
    end
  end
end