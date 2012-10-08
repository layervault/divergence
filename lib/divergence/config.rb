module Divergence
  class Configuration
    include Enumerable

    attr_accessor :app_path, :git_path
    attr_accessor :forward_host, :forward_port

    def initialize
      @git_path = nil
      @app_path = nil
      @forward_host = 'localhost'
      @forward_port = 80
      @callback_store = {}

      @helpers = Divergence::Helpers.new(self)
    end

    # Might get rid of realpath in the future because it
    # resolves symlinks and that could be problematic
    # with capistrano in case someone accidentally deploys.
    def app_path=(p)
      @app_path = File.realpath(p)
    end

    def git_path=(p)
      @git_path = File.realpath(p)
    end

    def callbacks(name, &block)
      @callback_store[name] = block
    end

    def callback(name)
      return unless @callback_store.has_key?(name)

      Application.log.debug "Execute callback: #{name.to_s}"
      @helpers.execute @callback_store[name]
    end

    def each(&block)
      instance_variables.each do |key|
        if block_given?
          block.call key, instance_variable_get(key)
        else
          yield instance_variable_get(key)
        end
      end
    end
  end
end