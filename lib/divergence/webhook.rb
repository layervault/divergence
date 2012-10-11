module Divergence
  class Webhook
    def self.handle(git, req)
      hook = JSON.parse(req['payload'])
      branch = hook["ref"].split("/").last.strip

      Application.log.info "Webhook: received for #{branch} branch"

      # If the webhook is for the currently active branch,
      # then we perform a pull and a swap.
      if false
        Application.log.info "Webhook: updating #{branch}"

        git.prepare_directory(branch, true)
        git.swap!

        ok
      else
        ignore
      end
    end

    def self.ok
      [200, {"Content-Type" => "text/html"}, ["OK"]]
    end

    def self.ignore
      [200, {"Content-Type" => "text/html"}, ["IGNORE"]]
    end
  end
end