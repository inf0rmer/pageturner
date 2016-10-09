Hivent.configure do |config|
  config.backend         = :redis
  config.endpoint        = ENV["HIVENT_URL"]
  config.partition_count = 4
  config.client_id       = "builder"
end
