module Divergence
  class Application
    @config = {}
    
    def configure(&block)
      block.call(self.config)
    end
  end
end