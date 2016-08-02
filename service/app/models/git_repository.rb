module Models
  class GitRepository
    GIT_REMOTE_URL = "git@github.com"

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def update
      repo.fetch
      repo.checkout(ENV["MONITORED_BRANCH"])
      repo.pull
    end

    def repo
      return @repo if @repo

      clone unless Dir.exists?(repository_path)
      @repo = Git.open(repository_path)
    end

    private

    def repository_url
      "#{GIT_REMOTE_URL}:#{name}.git"
    end

    def repository_path
      "/tmp/repos/#{name}"
    end

    def clone
      path = File.dirname(repository_path)

      Git.clone(repository_url, name, path: path)
    end
  end
end
