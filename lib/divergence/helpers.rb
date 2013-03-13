module Divergence
  class Helpers
    def initialize(config)
      @config = config
    end

    def execute(block, opts={})
      self.instance_exec opts, &block
    end

    private

    def bundle_install(opts={})
      Application.log.debug "bundle install"

      begin
        cmd = 'bundle install'
        cmd << ' --deployment' if opts[:deployment]
        cmd << " --path #{opts[:path]}" if opts[:path]
        cmd << ' --without development test'
        result = `#{cmd}`
        Application.log.debug result
      rescue
        Application.log.error "bundle install failed!"
        Application.log.error e.message
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

    def restart_unicorn
      Application.log.debug "Restarting unicorn..."
      begin
        unicorn_pid_file = File.join(config.app_path, "tmp/pids/unicorn.pid")
        cmd = "cat #{unicorn_pid_file} | xargs kill -USR2"
        result = `#{cmd}`
        Application.log.debug result
      rescue
      end
    end
  end
end