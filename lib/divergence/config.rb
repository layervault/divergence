module Divergence
  class Configuration
    attr_accessor :path

    def initialize
      @path = ''
    end
  end

  class Application
    @@config = Configuration.new

    def self.configure(&block)
      block.call(@@config)
    end
  end
end