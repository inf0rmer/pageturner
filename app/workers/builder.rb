module Workers
  class Builder
    def initialize(repo)
      @repo = repo
    end

    def build!
      @repo.update

      pid = fork do
        Bundler.with_clean_env { install! }
      end

      Process.wait pid

      deploy!

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
        Kernel.exec("bundle install && bundle exec jekyll build -d /sites/#{@repo.name}")
      end
    end

    def deploy!
      S3Uploader.upload(
        "/sites/#{@repo.name}",
        build_options[:bucket],
        {
          s3_key:          build_options[:s3_key],
          s3_secret:       build_options[:s3_secret],
          destination_dir: "#{@repo.name}/#{Time.now.to_i}",
          region:          build_options[:region]
        }
      )
    end
  end
end
