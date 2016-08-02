module Workers
  class Builder
    def initialize(repo)
      @repo = repo
    end

    def build!
      @repo.update

      Dir.chdir(@repo.repository_path) {
        Kernel.exec(["bundle", "install"])
        Kernel.exec(["bundle", "exec", "jekyll", "build"])
      }
    end
  end
end
