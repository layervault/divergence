module Divergence
  class GitManager
    def initialize(config)
      @config = config
      @app_path = config.app_path
      @git_path = config.git_path

      @log = Logger.new('./log/git.log')
      @git = Git.open(@git_path, :log => @log)

      @current_branch = @git.branch
      @new_branch = false
    end

    def prepare_directory(branch)
      pull branch unless is_current?(branch)
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
      
      @log.info "Swap: #{@git_path} -> #{@app_path}"
      `rsync -a --exclude=.git #{@git_path}/* #{@app_path}`
      @new_branch = false

      Dir.chdir @config.app_path do
        @config.callback :after_swap
      end
    end

    # Since underscores are technically not allowed in URLs,
    # but they are allowed in Git branch names, we have to do
    # some magic to possibly convert dashes to underscores
    # so we can load the right branch.
    def discover(branch)
      return branch if @git.is_branch?(branch)

      # First, we get the indicies of all the dashes in the
      # given branch name.
      indices = []
      branch.scan(/-/) do |c|
        indices << $~.offset(0)[0]
      end

      # Now we test all permutations of the string to see which
      # branch exists.
      tested = {}
      for i in 0..indices.length
        perm = indices.permutation(i).to_a

        perm.each do |p|
          # Don't want to modify the original
          test = String.new(branch)

          p.each do |index|
            test[index] = "_"
          end

          next if tested.has_key?(test)
          tested[test] = true
          
          return test if @git.is_branch?(test)
        end        
      end
    end

    private

    def is_current?(branch)
      @current_branch == branch
    end

    def pull(branch)
      if checkout(branch)
        #@git.pull 'origin', branch
        @git.chdir do
          # For some reason, I'm having issues with the pull
          # that's built into the library. Doing this manually
          # for now.
          `git pull origin #{branch} 2>&1`
        end
      else
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