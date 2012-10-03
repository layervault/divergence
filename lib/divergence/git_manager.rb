require 'find'
require 'fileutils'

module Divergence
  class GitManager
    def initialize(git_path, app_path)
      @app_path = app_path
      @git_path = git_path
      @git = Git.open(git_path)
    end

    def prepare_directory(branch)
      pull branch unless is_current?(branch)
    end

    # Performs the swap between the git directory and the working
    # app directory. We want to copy the files without copying
    # the .git directory, but this is a temporary dumb solution.
    # TODO: make this more ruby-like.
    def swap!
      `rsync -a --exclude=.git #{@git_path}/* #{@app_path}`
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