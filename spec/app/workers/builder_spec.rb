describe Workers::Builder do
  let(:builder)   { described_class.new(repo) }
  let(:repo)      { instance_double("Models::GitRepository").as_null_object }
  let(:repo_name) { "octocat/Hello-World" }

  before :all do
    Timecop.freeze
  end

  after :all do
    Timecop.return
  end

  before :each do
    allow(repo).to receive(:name).and_return(repo_name)
  end

  describe "#build!" do
    subject { builder.build! }

    let(:pid) { 12345 }

    before :each do
      allow(repo).to receive(:clone)
      allow(repo).to receive(:update)

      allow(builder).to receive(:fork) do |&block|
        block.call
        pid
      end

      allow(builder).to receive(:before_build)

      allow(Dir).to receive(:chdir) { |&block| block.call }
      allow(Kernel).to receive(:exec)
      allow(Process).to receive(:wait).with(pid)

      allow(S3Uploader).to receive(:upload)
    end

    it "calls #before_build" do
      subject

      expect(builder).to have_received(:before_build)
    end

    it "updates the repo" do
      subject

      expect(repo).to have_received(:update)
    end

    it "changes the directory to the repo's path" do
      subject

      expect(Dir).to have_received(:chdir).with(repo.repository_path)
    end

    it "builds a Jekyll project in the repo's directory" do
      subject

      expect(Kernel).to have_received(:exec)
        .with("bundle install && bundle exec jekyll build -d /sites/#{repo_name}")
    end

    it "uploads the built project into an S3 bucket" do
      subject

      expect(S3Uploader).to have_received(:upload).with(
        "/sites/#{repo_name}",
        ENV["S3_BUCKET_NAME"],
        {
          s3_key:          ENV["AWS_ACCESS_KEY_ID"],
          s3_secret:       ENV["AWS_SECRET_KEY"],
          destination_dir: "#{repo_name}/#{Time.now.to_i}",
          region:          ENV["AWS_REGION"]
        }
      )
    end

  end

  describe "#before_build" do
    subject { builder.before_build }

    let(:exchange) { $rabbitmq_channel.topic("builds", durable: true) }
    let(:queue)    { $rabbitmq_channel.queue("a_service") }

    before :each do
      queue.bind(exchange, routing_key: "build:started")
    end

    it "publishes a 'build:started' event" do
      expect { subject }.to change { queue.message_count }.by(1)
    end

    describe "the event payload" do
      subject { JSON.parse(queue.pop.last).with_indifferent_access }

      before :each do
        builder.before_build
      end

      its([:name])                 { is_expected.to eq("build:started") }
      its([:meta, :created_at])    { is_expected.to eq(Time.now.iso8601(9)) }
      its([:meta, :cid])           { is_expected.to be_a(String) }
      its([:meta, :version])       { is_expected.to eq(1) }
      its([:payload, :repository]) { is_expected.to eq(repo_name) }
    end
  end

  describe "#after_build" do
    subject { builder.after_build }

    let(:exchange) { $rabbitmq_channel.topic("builds", durable: true) }
    let(:queue)    { $rabbitmq_channel.queue("b_service") }

    before :each do
      queue.bind(exchange, routing_key: "build:finished")
    end

    it "publishes a 'build:finished' event" do
      expect { subject }.to change { queue.message_count }.by(1)
    end

    describe "the event payload" do
      subject { JSON.parse(queue.pop.last).with_indifferent_access }

      let(:deploy_location) do
        {
          host:   "s3",
          bucket: ENV["S3_BUCKET_NAME"],
          object: "#{repo_name}/#{Time.now.to_i}"
        }.with_indifferent_access
      end

      before :each do
        builder.after_build
      end

      its([:name])       { is_expected.to eq("build:finished") }
      its([:meta, :created_at])    { is_expected.to eq(Time.now.iso8601(9)) }
      its([:meta, :cid])           { is_expected.to be_a(String) }
      its([:meta, :version])       { is_expected.to eq(1) }
      its([:payload, :repository]) { is_expected.to eq(repo_name) }
      its([:payload, :location])   { is_expected.to eq(deploy_location) }
    end
  end
end
