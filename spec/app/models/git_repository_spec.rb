describe Models::GitRepository do
  subject { described_class.new(repo_name) }

  let(:repo_name) { "octocat/Hello-World" }
  let(:double) { instance_double("Git::Base") }

  before :each do
    allow(Git).to receive(:clone)
    allow(Git).to receive(:open) { double }
    allow(double).to receive(:config)
  end

  describe '.new' do
    it "configures the git username and email" do
      subject

      expect(double).to have_received(:config).with("user.name", ENV["GIT_USER_NAME"])
      expect(double).to have_received(:config).with("user.email", ENV["GIT_USER_EMAIL"])
    end
  end

  describe "#repository_path" do
    subject { super().repository_path }

    it { is_expected.to eq("/tmp/repos/#{repo_name}") }
  end

  describe "#repo" do
    subject { super().repo }

    before :each do
      allow(Git).to receive(:open) { instance_double("Git::Base").as_null_object }
    end

    it "returns the git repo" do
      is_expected.to be
    end

    context "when folder does not exist" do
      let(:path) { "/tmp/repos" }

      before do
        allow(Dir).to receive(:exists?) { false }
      end

      it "clones the repository" do
        subject

        expect(Git).to have_received(:clone)
          .with("https://github.com/#{repo_name}.git", repo_name, path: path)
      end
    end

    context "when folder exists" do
      before :each do
        allow(Git).to receive(:clone)
        allow(Dir).to receive(:exists?) { true }
      end

      it "does not clone the repository" do
        expect(Git).to_not have_received(:clone)
      end
    end
  end

  describe "#update" do
    subject      { super().update }
    let(:double) { instance_double("Git::Base") }

    before :each do
      allow(Git).to receive(:open) { double }
      allow(double).to receive(:config)
      allow(double).to receive(:checkout)
      allow(double).to receive(:fetch)
    end

    it "fetches the repo with the configured branch" do
      subject

      expect(double).to have_received(:fetch).ordered
      expect(double).to have_received(:checkout).with(ENV["MONITORED_BRANCH"]).ordered
    end
  end
end
