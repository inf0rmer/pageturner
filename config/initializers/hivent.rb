# frozen_string_literal: true
require "app/support/life_cycle_event_handler"

Hivent.configure do |config|
  config.backend                  = :redis
  config.endpoint                 = ENV["HIVENT_URL"]
  config.partition_count          = ENV["HIVENT_PARTITION_COUNT"].to_i
  config.client_id                = "builder"
  config.life_cycle_event_handler = LifeCycleEventHandler.new
end
