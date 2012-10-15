module Divergence
  # Responsible for managing the cache folders and swapping
  # the codebases around.
  class Application < Rack::Proxy
    # Prepares the filesystem for loading up a branch
    def prepare(branch, opts = {})
      return nil if branch == @active_branch

      unless @cache.is_cached?(branch)
        @cache.add branch, @git.switch(branch)
      end

      @cache.path(branch)
    end

    # Links the application directory to the given path,
    # which is always a cache directory in our case.
    def link!(path)
      Application.log.info "Link: #{path} -> #{config.app_path}"

      config.callback :before_swap, path
      FileUtils.rm config.app_path if File.exists?(config.app_path)
      FileUtils.ln_s path, config.app_path, :force => true
      config.callback :after_swap, config.app_path
    end
  end
end