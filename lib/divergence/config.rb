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

    def ok?
      [:git_path, :app_path, :cache_path].each do |path|
        if instance_variable_get("@#{path}").nil?
          raise "Configure #{path} before running"
        end
      end

      unless File.exists?(@git_path)
        raise "Configured git path not found: #{@git_path}"
      end

      unless File.exists?(@cache_path)
        FileUtils.mkdir_p @cache_path
      end
    end

    # Lets a user define a callback for a specific event
    def callbacks(*names, &block)
      names.each do |name|
        unless @callback_store.has_key?(name)
          @callback_store[name] = []
        end

        @callback_store[name].push block
      end
    end

    def callback(name, run_path=nil, args = {})
      return unless @callback_store.has_key?(name)

      if run_path.nil? or !File.exists?(run_path)
        run_path = Dir.pwd
      end

      Application.log.debug "Execute callback: #{name.to_s} in #{run_path}"

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