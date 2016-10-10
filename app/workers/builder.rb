module Workers
  class Builder

    # 10 minutes max build time
    BUILD_TIMEOUT = 10 * 60

    def initialize(event)
      @event = event
    end

    def build!
      before_build

      run_container!

      after_build
    end

    private

    def before_build
      Hivent::Signal.new("build:started").emit({
        repository: repository_name
      }, version: 1, cid: @event[:meta][:cid])
    end

    def after_build
      delete_container!

      Hivent::Signal.new("build:finished").emit({
        repository: repository_name,
        location:   deploy_location
      }, version: 1, cid: @event[:meta][:cid])
    end

    def container
      @container ||= Docker::Image.create(fromImage: "pageturner/jekyll-builder")
    end

    def run_container!
      container
        .run(nil,
          Env: [
            "AWS_ACCESS_KEY_ID=#{ENV['AWS_ACCESS_KEY_ID']}",
            "AWS_SECRET_ACCESS_KEY=#{ENV['AWS_SECRET_ACCESS_KEY']}",
            "REPOSITORY_TARBALL_URL=#{tarball_url}",
            "BUCKET_PATH=#{s3_bucket_path}"
          ]
        )
        .wait(BUILD_TIMEOUT)
    end

    def delete_container!
      container.remove
    end

    def tarball_url
      "https://github.com/#{repository_name}/tarball/#{ENV['MONITORED_BRANCH']}"
    end

    def s3_bucket_path
      "s3://#{ENV['S3_BUCKET_NAME']}/#{repository_name}/#{Time.now.to_i}"
    end

    def repository_name
      @event[:payload][:repository]
    end

    def build_options
      {
        bucket:    ENV["S3_BUCKET_NAME"],
        s3_key:    ENV["AWS_ACCESS_KEY_ID"],
        s3_secret: ENV["AWS_SECRET_ACCESS_KEY"],
        region:    ENV["AWS_REGION"]
      }
    end

    def deploy_location
      @deploy_location ||= {
        host:   "s3",
        bucket: build_options[:bucket],
        object: "#{repository_name}/#{Time.now.to_i}"
      }
    end
  end
end
