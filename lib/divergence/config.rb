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
    end

    def app_path=(p)
      @app_path = File.realpath(p)
    end

    def git_path=(p)
      @git_path = File.realpath(p)
    end

    def each(&block)
      instance_variables.each do |v|
        if block_given?
          block.call instance_variable_get(v)
        else
          yield instance_variable_get(v)
        end
      end
    end
  end
end