module Divergence
  class CacheManager
    def initialize(cache_path, cache_num)
      @cache_path = cache_path
      @cache_num = cache_num

      Dir.chdir @cache_path do
        @cached_branches = Dir['*/'].map {|dir| dir.gsub('/', '')}
      end
    end

    def is_cached?(branch)
      @cached_branches.include?(branch)
    end

    def add(branch, src_path)
      Application.log.info "Caching: #{branch} from #{src_path}"

      prune_cache!

      Application.config.callback :before_cache, src_path, :branch => branch

      FileUtils.mkdir_p path(branch)
      sync branch, src_path
      @cached_branches.push branch

      Application.config.callback :after_cache, path(branch), :branch => branch
    end

    def sync(branch, src_path)
      `rsync -a --delete --exclude .git --exclude .gitignore #{src_path}/ #{path(branch)}`
    end

    def path(branch)
      "#{@cache_path}/#{branch}"
    end

    private

    # Delete the oldest cached branches to make room for new
    def prune_cache!
      Dir.chdir @cache_path do
        branches = Dir.glob('*/')
        return if branches.nil? or branches.length <= @cache_num

        branches \
          .sort_by {|f| File.mtime(f)}[@cache_num..-1] \
          .each do|dir|
            FileUtils.rm_rf(dir)
            @cached_branches.delete(dir.gsub('/', ''))
          end
      end
    end
  end
end
