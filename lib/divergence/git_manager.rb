require 'logger'

module Divergence
  class GitManager
    def initialize(path)
      @git = Git.open(path)
    end

    def prepare_directory(branch)
      pull branch unless is_current?(branch)
    end

    private

    def is_current?(branch)
      @git.branch(branch).current
    end

    def pull(branch)
      checkout branch
      @git.pull :origin, branch
    end

    def checkout(branch)
      fetch
      reset
      @git.branch(branch).checkout
    end

    def reset
      @git.reset_hard('HEAD')
    end

    # Fetch all remote branch information
    def fetch
      @git.fetch
    end
  end
end