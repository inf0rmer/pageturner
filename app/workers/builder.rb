module Workers
  class Builder

    def initialize(repo)
      @repo = repo
    end

    def build!
      before_build

      @repo.update

      pid = fork do
        Bundler.with_clean_env { install! }
      end

      Process.wait pid

      deploy!

      after_build
    end

    def before_build
      Hivent::Signal.new("build:started").emit({
        repository: @repo.name
      }, version: 1)
    end

    def after_build
      Hivent::Signal.new("build:finished").emit({
        repository: @repo.name,
        location:   deploy_location
      }, version: 1)
    end

    private

    def build_options
      {
        bucket:    ENV["S3_BUCKET_NAME"],
        s3_key:    ENV["AWS_ACCESS_KEY_ID"],
        s3_secret: ENV["AWS_SECRET_KEY"],
        region:    ENV["AWS_REGION"]
      }
    end

    def install!(options = {})
      Dir.chdir(@repo.repository_path) do
        Kernel.exec("bundle install && bundle exec jekyll build -d #{build_location}")
      end
    end

    def deploy_location
      @deploy_location ||= {
        host:   "s3",
        bucket: build_options[:bucket],
        object: "#{@repo.name}/#{Time.now.to_i}"
      }
    end

    def build_location
      "/sites/#{@repo.name}"
    end

    def deploy!
      S3Uploader.upload(
        build_location,
        build_options[:bucket],
        {
          s3_key:          build_options[:s3_key],
          s3_secret:       build_options[:s3_secret],
          destination_dir: deploy_location[:object],
          region:          build_options[:region]
        }
      )
    end
  end
end
