Rollbar.configure do |config|
  config.disable_monkey_patch = true

  config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
  config.environment  = ENV["APP_ENV"]

  unless %w( production staging ).include?(ENV["APP_ENV"])
    config.enabled = false
  end

  config.exception_level_filters.merge!("Sinatra::NotFound" => "warning")
end
