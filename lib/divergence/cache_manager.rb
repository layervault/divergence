module Divergence
  class CacheManager
    def initialize(cache_path, cache_num)
      @cache_path = cache_path
      @cache_num = cache_num

      Dir.chdir @cache_path do
        @cached_branches = Dir['*/'].map {|dir| dir.sub('/', '')}
      end
    end

    def is_cached?(branch)
      @cached_branches.include?(branch)
    end

    def add(branch, src_path)
      Application.log.info "Caching: #{branch} from #{src_path}"

      prune_cache!

      @config.callback :before_cache, src_path, :branch => branch
      `rsync -a --delete --exclude=.git #{src_path}/* #{path(branch)}`
      @config.callback :after_cache, path(branch), :branch => branch
    end

    private

    def path(branch)
      "#{@cache_path}/#{branch}"
    end

    def prune_cache!
      Dir.chdir @cache_path do
        Dir['*/']
          .sort_by {|f| File.mtime(f)}[@cache_num..-1]
          .each {|dir| FileUtils.rm_rf(dir)}
      end
    end
  end
end