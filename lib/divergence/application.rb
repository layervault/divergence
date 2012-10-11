module Divergence
  # Responsible for managing the cache folders and swapping
  # the codebases around.
  class Application < Rack::Proxy
    def prepare(branch)
      return nil if branch == @active_branch

      unless @cache.is_cached?(branch)
        @cache.add branch, @git.switch(branch)
      end

      @cache.path(branch)
    end

    def swap!(path)
      FileUtils.ln_s path, config.app_path, :force => true
    end
  end
end