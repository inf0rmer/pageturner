module Events
  BUILD_STARTED_EVENT  = "build:started".freeze
  BUILD_FINISHED_EVENT = "build:finished".freeze

  def publish(event)
    exchange.publish(event[:message].to_json, event[:options])
  end

  def build_started_event
    {
      message: {
        name: BUILD_STARTED_EVENT,
        id:   SecureRandom.hex,
        meta: metadata,
        payload: {
          repository: @repo.name
        }
      },
      options: {
        routing_key: BUILD_STARTED_EVENT
      }
    }
  end

  def build_finished_event
    {
      message: {
        name: BUILD_FINISHED_EVENT,
        id:   SecureRandom.hex,
        meta: metadata,
        payload: {
          repository: @repo.name,
          location:   deploy_location
        }
      },
      options: {
        routing_key: BUILD_FINISHED_EVENT
      }
    }
  end

  private

  def exchange
    @exchange ||= $rabbitmq_channel.topic("builds", durable: true)
  end

  def metadata
    {
      created_at: Time.now.iso8601(9),
      cid:        SecureRandom.hex,
      version:    1
    }
  end

end
