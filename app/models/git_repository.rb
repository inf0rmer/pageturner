module Models
  class GitRepository
    GIT_REMOTE_URL = "https://github.com".freeze
    REPOS_PATH     = "/tmp/repos".freeze

    attr_reader :name

    def initialize(name)
      @name = name

      repo.config("user.name", ENV["GIT_USER_NAME"])
      repo.config("user.email", ENV["GIT_USER_EMAIL"])
    end

    def update
      repo.fetch
      repo.checkout(ENV["MONITORED_BRANCH"])
    end

    def repo
      return @repo if @repo

      clone unless Dir.exists?(repository_path)
      @repo = Git.open(repository_path)
    end

    def repository_path
      "#{REPOS_PATH}/#{name}"
    end

    private

    def repository_url
      "#{GIT_REMOTE_URL}/#{name}.git"
    end

    def clone
      Git.clone(repository_url, name, path: REPOS_PATH)
    end
  end
end
