# frozen_string_literal: true
require "app/workers/builder"

module Consumers

  class BuildRequests

    EVENT_NAME = "build:requested"

    def consume!
      signal.receive(version: 1) do |event|
        Workers::Builder.new(event).build!
      end
    end

    private

    def signal
      @signal ||= Hivent::Signal.new(EVENT_NAME)
    end

  end

end
