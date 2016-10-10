Docker.url = ENV["DOCKER_URL"]

Docker.validate_version! if ENV["APP_ENV"] != "test"
