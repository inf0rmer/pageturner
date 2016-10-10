# frozen_string_literal: true
if ENV["CODECLIMATE_REPO_TOKEN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
else
  require "simplecov"
end

ENV["APP_ENV"] = "test"

require_relative "../boot"
require "hivent/rspec"

Dir[APP_ROOT / "spec" / "support" / "**" / "*.rb"].each { |f| require f }
