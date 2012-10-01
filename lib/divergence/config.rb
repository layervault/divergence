module Divergence
  class Configuration
    attr_accessor :path

    def initialize
      @path = '/'
    end

    def path=(p)
      @path = File.realpath(p)
    end
  end
end