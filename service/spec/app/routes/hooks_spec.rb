describe Routes::Hooks do

  describe "POST /hooks" do
    subject         { post "/hooks", params }

    let(:params)    { {} }
    let(:event)     { "event" }
    let(:signature) { "sha1=signature" }

    before :each do
      ENV['WEBHOOK_SECRET'] = "your_token"

      header "X-Github-Event", event
      header "X-Hub-Signature", signature
    end

    context "When the request does not have a valid digest hash" do
      let(:signature) { "sha1=invalid" }
      let(:event)     { "push" }

      it "responds with a 401 Unauthorized, with a JSON error" do
        subject

        expect(last_response.status).to eq 401
        expect(last_response.headers['Content-Type']).to eq("application/json")
      end
    end

    context "When the request does not have a \"X-Github-Event\" header with the value \"push\"" do
      let(:event) { "pull" }

      it "responds with a 200" do
        subject

        expect(last_response.status).to eq 200
      end
    end

    context "When the request is authenticated" do
      let(:signature) do
        "sha1=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['WEBHOOK_SECRET'], params.to_json)}"
      end
      let(:params) do
        {
          ref: "refs/heads/#{ENV['MONITORED_BRANCH']}",
          repository: {
            full_name: repo_name
          }
        }
      end
      let(:repo_name) { "octocat/Hello-World" }
      let(:event)     { "push" }
      let(:repo)      { instance_double("Models::GitRepository") }
      let(:builder)   { instance_double("Builder") }

      before do
        allow(Models::GitRepository).to receive(:new).with(repo_name) { repo }

        allow(Builder).to receive(:new).with(repo) { builder }
        allow(builder).to receive(:build!)
      end

      it "calls Builder#build! with the given repo" do
        subject

        expect(builder).to have_received(:build!)
      end

      it "responds with 201 Created" do
        subject

        expect(last_response.status).to eq(201)
      end

      context "When the event refers to a branch that is not 'ENV[\"MONITORED_BRANCH\"]'" do
        let(:params) { { ref: "refs/heads/some_branch" } }

        it "responds with a 200" do
          subject
          expect(last_response.status).to eq 200
        end
      end
    end

  end

end
