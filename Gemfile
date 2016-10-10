# frozen_string_literal: true
source "https://rubygems.org"

# Prevent invalid byte sequence in US-ASCII (Encoding::InvalidByteSequenceError)
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# common gems
gem "json"
gem "activesupport"
gem "dotenv"
gem "rollbar"

# App specifics
gem "hivent"
gem "docker-api"

# Deployment
gem "foreman"

group :development, :test do
  gem "guard"
  gem "guard-rspec"
  gem "pry-byebug"
  gem "rubocop"
end

group :test do
  gem "rspec"
  gem "rspec-its"
  gem "json_spec"
  gem "timecop"

  # code coverage
  gem "simplecov",                 require: false
  gem "codeclimate-test-reporter", require: false
end
