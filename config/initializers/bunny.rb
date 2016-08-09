file = APP_ROOT.join("config.yml")
config = ::YAML.load(ERB.new(File.read(file)).result)[ENV['APP_ENV']]

ENV["RABBITMQ_URL"] ||= config["rabbitmq"]["url"]
