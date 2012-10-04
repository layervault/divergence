require 'find'
require 'fileutils'

module Divergence
  class GitManager
    def initialize(git_path, app_path)
      @app_path = app_path
      @git_path = git_path

      @log = Logger.new('./log/git.log')
      @git = Git.open(git_path, :log => @log)

      @current_branch = @git.branch
      @new_branch = false
    end

    def prepare_directory(branch)
      pull branch unless is_current?(branch)
    end

    # Performs the swap between the git directory and the working
    # app directory. We want to copy the files without copying
    # the .git directory, but this is a temporary dumb solution.
    # TODO: make this more ruby-like.
    def swap!
      return unless @new_branch
      
      @log.info "Swap: #{@git_path} -> #{@app_path}"
      `rsync -a --exclude=.git #{@git_path}/* #{@app_path}`
      @new_branch = false
    end

    private

    def is_current?(branch)
      @current_branch == branch
    end

    def pull(branch)
      if checkout(branch)
        @git.pull :origin, branch
      else
        return false
      end
    end

    def checkout(branch)
      fetch
      reset
      
      begin
        @git.checkout branch
        @current_branch = branch
        @new_branch = true
      rescue
        return false
      end
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