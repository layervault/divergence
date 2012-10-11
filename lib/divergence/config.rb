module Divergence
  class Configuration
    include Enumerable

    attr_accessor :app_path, :git_path, :cache_path
    attr_accessor :cache_num
    attr_accessor :forward_host, :forward_port

    def initialize
      @git_path = nil
      @app_path = nil
      @cache_path = nil

      @cache_num = 5

      @forward_host = 'localhost'
      @forward_port = 80

      @callback_store = {}
      @helpers = Divergence::Helpers.new(self)
    end

    # Might get rid of realpath in the future because it
    # resolves symlinks and that could be problematic
    # with capistrano in case someone accidentally deploys.
    #def app_path=(p)
    #  @app_path = File.realpath(p)
    #end

    #def git_path=(p)
    #  @git_path = File.realpath(p)
    #end

    #def cache_path=(p)
    #  @cache_path = File.realpath(p)
    #end

    # Lets a user define a callback for a specific event
    def callbacks(name, &block)
      unless @callback_store.has_key?(name)
        @callback_store[name] = []
      end

      @callback_store[name].push block
    end

    def callback(name, run_path=nil, args = {})
      return unless @callback_store.has_key?(name)

      Application.log.debug "Execute callback: #{name.to_s}"

      if run_path.nil? or !File.exists?(run_path)
        run_path = Dir.pwd
      end

      Dir.chdir run_path do
        @callback_store[name].each do |cb|
          @helpers.execute cb, args
        end
      end
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