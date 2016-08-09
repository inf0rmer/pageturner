if ENV["CODECLIMATE_REPO_TOKEN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
else
  require "simplecov"
end

ENV["APP_ENV"] = "test"

require_relative "../boot"
require "app"
require "rack/test"
require "sidekiq/testing"
require "bunny-mock"

Dir[APP_ROOT / "spec" / "support" / "**" / "*.rb"].each { |f| require f }

module RSpecMixin

  include Rack::Test::Methods
  Sidekiq::Testing.inline!

  def app
    App
  end

end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include JsonSpec::Helpers

  config.before :each do
    stub_const("Bunny", BunnyMock)
  end
end
