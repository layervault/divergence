module Divergence
  class Application
    def handle_webhook
      hook = JSON.parse(@req['payload'])
      branch = hook["ref"].split("/").last.strip

      Application.log.info "Webhook: received for #{branch} branch"

      # If the webhook is for the currently active branch,
      # then we perform a pull and a swap.
      if @cache.is_cached?(branch)
        Application.log.info "Webhook: updating #{branch}"

        git_path = @git.switch branch, :force => true

        config.callback :before_webhook, git_path, :branch => branch
        @cache.sync branch, git_path
        config.callback :after_webhook, @cache.path(branch), :branch => branch

        ok
      else
        Application.log.info "Webhook: ignoring #{branch}"
        ignore
      end
    end

    def ok
      [200, {"Content-Type" => "text/html"}, ["OK"]]
    end

    def ignore
      [200, {"Content-Type" => "text/html"}, ["IGNORE"]]
    end
  end
end