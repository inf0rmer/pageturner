require_relative "./boot"

Dir[APP_ROOT / "config" / "initializers" / "**" / "*.rb"].each { |f| require f }

require "app/consumers/build_requests"
