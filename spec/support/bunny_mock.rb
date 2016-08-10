require "bunny"

BunnyMock.use_bunny_queue_pop_api = true

module Bunny
  def self.new(*args)
    @@_instance ||= BunnyMock.new(*args)
  end
end
