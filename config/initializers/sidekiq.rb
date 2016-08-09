file = APP_ROOT.join("config.yml")
config = ::YAML.load(ERB.new(File.read(file)).result)[ENV['APP_ENV']]
redis_url = config["redis"]["url"]

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
