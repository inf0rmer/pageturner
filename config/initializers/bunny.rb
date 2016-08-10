file = APP_ROOT.join("config.yml")
config = ::YAML.load(ERB.new(File.read(file)).result)[ENV['APP_ENV']]

ENV["RABBITMQ_URL"] ||= config["rabbitmq"]["url"]

$rabbitmq_connection = Bunny.new
$rabbitmq_connection.start

$rabbitmq_channel = $rabbitmq_connection.create_channel
