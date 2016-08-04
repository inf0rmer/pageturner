require "jobs/builder"

module Routes
  class Hooks < ApiBase

    before "/hooks", method: :post, provides: :json do
      halt(200) if env['HTTP_X_GITHUB_EVENT'] != "push"
    end

    before "/hooks", method: :post, provides: :json do
      if env['HTTP_X_HUB_SIGNATURE'] != hashed_token
        halt 401, {}, unauthorized_error.to_json
      end
    end

    before "/hooks", method: :post, provides: :json do
      halt(200) if params["ref"] != "refs/heads/#{ENV['MONITORED_BRANCH']}"
    end

    post "/hooks" do
      Builder.perform_async(repo_name)

      [201, {}, {}]
    end

    private

    def hashed_token
      'sha1='+OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['WEBHOOK_SECRET'], params.to_json)
    end

    def repo_name
      params.dig("repository", "full_name")
    end

    def unauthorized_error
      {
        error: {
          status: "401",
          code: "invalid_webhook_secret_hash",
          title: "Invalid webhook secret",
          detail: "Thr provided webhook secret is incorrect"
        }
      }
    end

  end
end
