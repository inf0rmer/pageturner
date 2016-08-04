module Workers
  class Builder
    include Process

    def initialize(repo)
      @repo = repo
    end

    def build!
      @repo.update


      pid = fork

      if pid == nil
        Bundler.with_clean_env do
          Dir.chdir(@repo.repository_path) do
            Kernel.exec("bundle install && bundle exec jekyll build -d /sites/#{@repo.name}")
          end
        end
      end

      wait pid

    end
  end
end
