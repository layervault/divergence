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

      begin
        result = `bundle install --deployment --without development test`
        Application.log.debug result
      rescue
        Application.log.debug "bundle install failed!"
      end
    end

    def restart_passenger
      Application.log.debug "Restarting passenger..."

      begin
        unless File.exists? 'tmp'
          FileUtils.mkdir_p 'tmp'
        end

        FileUtils.touch 'tmp/restart.txt'
      rescue
      end
    end
  end
end