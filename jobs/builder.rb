require "app/models/git_repository"
require "app/workers/builder"

class Builder
  include Sidekiq::Worker

  def perform(repo_name)
    Models::GitRepository.new(repo_name).tap do |repo|
      Workers::Builder.new(repo).build!
    end
  end
end
