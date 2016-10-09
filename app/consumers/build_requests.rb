require "app/models/git_repository"
require "app/workers/builder"

module Consumers
  class BuildRequests
    EVENT_NAME = "build:requested".freeze

    def initialize
      @signal = Hivent::Signal.new(EVENT_NAME)
    end

    def consume!
      @signal.receive(version: 1) do |event|
        Models::GitRepository.new(event[:payload][:repository]).tap do |repo|
          Workers::Builder.new(repo).build!
        end
      end
    end
  end
end
