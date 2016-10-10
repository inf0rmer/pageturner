# frozen_string_literal: true
class LifeCycleEventHandler < Hivent::LifeCycleEventHandler

  def event_processing_failed(exception, payload, raw_payload, dead_letter_queue_name)
    Rollbar.error(
      exception,
      payload:                payload,
      raw_payload:            raw_payload,
      dead_letter_queue_name: dead_letter_queue_name
    )
  end

end
