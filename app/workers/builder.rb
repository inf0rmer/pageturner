module Workers
  class Builder
    include Process

    def initialize(repo)
      @repo = repo
    end

    def build!
      @repo.update

      fork do
        Bundler.with_clean_env { install_and_deploy! }
      end

    end

    private

    def install_and_deploy!
      Dir.chdir(@repo.repository_path) do
        Kernel.exec("bundle install && bundle exec jekyll build -d /sites/#{@repo.name}")
      end
    end
  end
end
