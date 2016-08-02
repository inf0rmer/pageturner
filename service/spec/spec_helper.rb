require "simplecov"

ENV["APP_ENV"]          = "test"
ENV["MONITORED_BRANCH"] = "monitored_branch"

require_relative "../boot"
require "app"
require "rack/test"

Dir[APP_ROOT / "spec" / "support" / "**" / "*.rb"].each { |f| require f }

module RSpecMixin

  include Rack::Test::Methods

  def app
    App
  end

end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include JsonSpec::Helpers
end
