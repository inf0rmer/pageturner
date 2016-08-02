describe Models::GitRepository do
  subject { described_class.new(repo_name) }

  let(:repo_name) { "octocat/Hello-World" }

  before :each do
    allow(Git).to receive(:clone)
  end

  describe "#repo" do
    subject { super().repo }

    before :each do
      allow(Git).to receive(:open) { instance_double("Git::Base") }
    end

    it "returns the git repo" do
      is_expected.to be
    end

    context "when folder does not exist" do
      let(:path) { "/tmp/repos/#{File.dirname(repo_name)}" }

      before do
        allow(Dir).to receive(:exists?) { false }
      end

      it "clones the repository" do
        subject

        expect(Git).to have_received(:clone)
          .with("git@github.com:#{repo_name}.git", repo_name, path: path)
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
      allow(double).to receive(:pull)
      allow(double).to receive(:checkout)
      allow(double).to receive(:fetch)
    end

    it "fetches and pulls the repo with the configured branch" do
      subject

      expect(double).to have_received(:fetch).ordered
      expect(double).to have_received(:checkout).with(ENV["MONITORED_BRANCH"]).ordered
      expect(double).to have_received(:pull).ordered
    end
  end
end
