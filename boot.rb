# Requires Ruby standard library modules
require "json"

# Requires ActiveSupport core extensions
require "active_support"
require "active_support/core_ext"

# Initializes load path with gems listed in Gemfile
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __FILE__)
ENV["APP_ENV"] = ENV["RACK_ENV"] = ENV["APP_ENV"].presence || ENV["RACK_ENV"].presence || "development"
require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

ENV["GIT_USER_NAME"] = ENV["GIT_USER_NAME"].presence || "Pageturner Builder"
ENV["GIT_USER_EMAIL"] = ENV["GIT_USER_EMAIL"].presence || "builder@pageturner.io"

# Requires gems listed in Gemfile
Bundler.require(:default, ENV["APP_ENV"])

# Load dotenv
Dotenv.load(".env.#{ENV['APP_ENV']}", ".env")

# Define APP_ROOT
APP_ROOT = Pathname.new(File.expand_path("..", __FILE__))

$: << File.expand_path("../", __FILE__)
