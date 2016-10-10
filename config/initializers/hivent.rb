Hivent.configure do |config|
  config.backend         = :redis
  config.endpoint        = ENV["HIVENT_URL"]
  config.partition_count = ENV["HIVENT_PARTITION_COUNT"].to_i
  config.client_id       = "builder"
end
