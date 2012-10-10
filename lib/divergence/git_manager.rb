module Divergence
  class GitManager
    attr_reader :current_branch

    def initialize(config)
      @config = config
      @app_path = config.app_path
      @git_path = config.git_path

      @log = Logger.new('./log/git.log')
      @git = Git.open(@git_path, :log => @log)

      @current_branch = @git.branch
      @new_branch = false
    end

    def prepare_directory(branch, force=false)
      return if is_current?(branch) and !force
      pull branch
    end

    # Performs the swap between the git directory and the working
    # app directory. We want to copy the files without copying
    # the .git directory, but this is a temporary dumb solution.
    #
    # Future idea: try the capistrano route and simply symlink
    # to the git directory instead of copying files.
    #
    # TODO: make this more ruby-like.
    def swap!
      return unless @new_branch

      Dir.chdir @config.git_path do
        @config.callback :before_swap
      end

      Application.log.info "Swap: #{@git_path} -> #{@app_path}"
      `rsync -a --delete --exclude=.git #{@git_path}/* #{@app_path}`
      @new_branch = false

      Dir.chdir @config.app_path do
        @config.callback :after_swap
      end
    end

    # Since underscores are technically not allowed in URLs,
    # but they are allowed in Git branch names, we have to do
    # some magic to possibly convert dashes to underscores
    # so we can load the right branch.
    #
    # Another possible thing to explore is converting all
    # dashes in the URL to a regex search against all branches
    # in this repository to avoid the current brute-force
    # solution we're using.
    def discover(branch)
      return branch if is_branch?(branch)

      Dir.chdir @git_path do
        resp = @config.callback :on_branch_discover, branch

        unless resp.nil?
          return resp
        end
      
        local_search = "^" + branch.gsub(/-/, ".") + "$"
        remote_search = "^remotes/origin/(" + branch.gsub(/-/, ".") + ")$"
        local_r = Regexp.new(local_search, Regexp::IGNORECASE)
        remote_r = Regexp.new(remote_search, Regexp::IGNORECASE)

        `git branch -a`.split("\n").each do |b|
          b = b.gsub('*', '').strip
          
          return b if local_r.match(b)
          if remote_r.match(b)
            return remote_r.match(b)[1]
          end
        end
      end

      raise "Unable to automatically detect branch. Given = #{branch}"
    end

    def is_current?(branch)
      @current_branch.to_s == branch
    end

    private

    def is_branch?(branch)
      Dir.chdir @git_path do
        # This is fast, but only works on locally checked out branches
        `git show-ref --verify --quiet 'refs/heads/#{branch}'`
        return true if $?.exitstatus == 0

        # This is slow and will only get called for remote branches.
        result = `git ls-remote --heads origin 'refs/heads/#{branch}'`
        return result.strip.length != 0
      end
    end

    def pull(branch)
      if checkout(branch)
        Dir.chdir @config.git_path do
          @config.callback :before_pull
        end

        #@git.pull 'origin', branch
        @git.chdir do
          # For some reason, I'm having issues with the pull
          # that's built into the library. Doing this manually
          # for now.
          @log.info "git pull origin #{branch} 2>&1"
          `git pull origin #{branch} 2>&1`
        end

        Dir.chdir @config.git_path do
          @config.callback :after_pull
        end
      else
        Dir.chdir @config.git_path do
          @config.callback :on_pull_error
        end

        return false
      end
    end

    def checkout(branch)
      fetch
      reset
      
      begin
        @git.checkout branch, :force => true
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