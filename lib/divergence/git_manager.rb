module Divergence
  # Manages the configured Git repository
  class GitManager
    attr_reader :current_branch

    def initialize(git_path)
      @git_path = git_path
      @log = Logger.new('./log/git.log')
      @current_branch = current_branch
    end

    def switch(branch, force=false)
      return @git_path if is_current?(branch) and !force
      
      pull branch
      return @git_path
    end

    # Since underscores are technically not allowed in URLs,
    # but they are allowed in Git branch names, we have to do
    # some magic to possibly convert dashes to underscores
    # so we can load the right branch.
    def discover(branch)
      return branch if is_branch?(branch)

      resp = Application.config.callback :on_branch_discover, @git_path, branch

      unless resp.nil?
        return resp
      end
    
      local_search = "^" + branch.gsub(/-/, ".") + "$"
      remote_search = "^remotes/origin/(" + branch.gsub(/-/, ".") + ")$"
      local_r = Regexp.new(local_search, Regexp::IGNORECASE)
      remote_r = Regexp.new(remote_search, Regexp::IGNORECASE)

      git('branch -a').split("\n").each do |b|
        b = b.gsub('*', '').strip
        
        return b if local_r.match(b)
        if remote_r.match(b)
          return remote_r.match(b)[1]
        end
      end 

      raise "Unable to automatically detect branch. Given = #{branch}"
    end

    def is_current?(branch)
      @current_branch.to_s == branch
    end

    private

    def current_branch
      git('branch -a').split("\n").each do |b|
        if b[0, 2] == '* '
          return b.gsub('* ', '').strip
        end
      end
    end

    def is_branch?(branch)
      # This is fast, but only works on locally checked out branches
      `git --git-dir #{@git_path}/.git  show-ref --verify --quiet 'refs/heads/#{branch}'`
      return true if $?.exitstatus == 0

      # This is slow and will only get called for remote branches.
      result = `git --git-dir #{@git_path}/.git ls-remote --heads origin 'refs/heads/#{branch}'`
      return result.strip.length != 0
    end

    def pull(branch)
      if checkout(branch)
        Application.config.callback :before_pull, @git_path
        git "pull origin #{branch}"
        Application.config.callback :after_pull, @git_path
      else
        Application.config.callback :on_pull_error, @git_path

        return false
      end
    end

    def checkout(branch)
      fetch
      reset
      
      begin
        git "checkout -f #{branch}"
        @current_branch = branch
      rescue
        return false
      end
    end

    def reset
      git 'reset --hard'
    end

    # Fetch all remote branch information
    def fetch
      git :fetch
    end

    def git(cmd)
      @log.info "git --work-tree #{@git_path} --git-dir #{@git_path}/.git #{cmd.to_s}"
      out = `git --work-tree #{@git_path} --git-dir #{@git_path}/.git #{cmd.to_s} 2>&1`

      if $?.exitstatus != 0
        Application.log.error "git --work-tree #{@git_path} --git-dir #{@git_path}/.git #{cmd.to_s} failed"
        Application.log.error out
      end

      return out
    end
  end
end
