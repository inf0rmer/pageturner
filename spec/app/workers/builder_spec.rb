require "app/workers/builder"

describe Workers::Builder do
  let(:builder)      { described_class.new(build_requested_event) }
  let(:repo_name)    { "octocat/Hello-World" }
  let(:docker_image) { double(Docker::Image) }
  let(:build_requested_event) do
    {
      payload: {
        repository: repo_name,
        source:     "github"
      },
      meta: { cid: SecureRandom.hex }
    }
  end

  before :all do
    Timecop.freeze
  end

  after :all do
    Timecop.return
  end

  describe "#build!" do
    subject { builder.build! }

    let(:project_tarball_url) do
      "https://github.com/#{repo_name}/tarball/#{ENV['MONITORED_BRANCH']}"
    end
    let(:s3_bucket_path) do
      "s3://#{ENV['S3_BUCKET_NAME']}/#{repo_name}/#{Time.now.to_i}"
    end
    let(:environment) do
      [
        "AWS_ACCESS_KEY_ID=#{ENV['AWS_ACCESS_KEY_ID']}",
        "AWS_SECRET_ACCESS_KEY=#{ENV['AWS_SECRET_ACCESS_KEY']}",
        "REPOSITORY_TARBALL_URL=#{project_tarball_url}",
        "BUCKET_PATH=#{s3_bucket_path}"
      ]
    end

    before :each do
      allow(Docker::Image).to receive(:create)
        .with(fromImage: "pageturner/jekyll-builder")
        .and_return(docker_image)

      allow(docker_image).to receive(:run)
      allow(docker_image).to receive(:remove)
    end

    context "before building" do

      it "publishes a 'build:started' event" do
        expect { subject }.to emit("build:started").with(
          repository: repo_name
        )
      end

      it "uses the cid from the event that triggered the build" do
        expect(subject[:meta][:cid]).to eq(build_requested_event[:meta][:cid])
      end

    end

    it "builds the project inside an ephemeral container, passing its environment configuration" do
      subject

      expect(docker_image).to have_received(:run)
        .with(nil, hash_including(Env: environment))
    end

    context "after building" do
      let(:deploy_location) do
        {
          host:   "s3",
          bucket: ENV["S3_BUCKET_NAME"],
          object: "#{repo_name}/#{Time.now.to_i}"
        }
      end

      it "deletes the docker image used to build the project" do
        subject

        expect(docker_image).to have_received(:remove)
      end

      describe "the 'build:finished' event" do

        it "publishes a 'build:finished' event" do
          expect { subject }.to emit("build:finished").with(
            repository: repo_name,
            location:   deploy_location
          )
        end

        it "uses the cid from the event that triggered the build" do
          expect(subject[:meta][:cid]).to eq(build_requested_event[:meta][:cid])
        end

      end
    end

  end
end
