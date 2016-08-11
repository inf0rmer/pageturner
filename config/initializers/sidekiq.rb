require "rollbar/plugins/sidekiq/plugin"

file = APP_ROOT.join("config.yml")
config = ::YAML.load(ERB.new(File.read(file)).result)[ENV['APP_ENV']]
redis_url = config["redis"]["url"]

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  config.server_middleware do |chain|
    chain.add Rollbar::Sidekiq::ClearScope
  end

  config.error_handlers << proc do |e, context|
    Rollbar::Sidekiq.handle_exception(context, e)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
