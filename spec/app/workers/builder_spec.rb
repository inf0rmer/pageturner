describe Workers::Builder do
  subject { described_class.new(repo) }

  let(:repo)      { instance_double("Models::GitRepository").as_null_object }
  let(:repo_name) { "octocat/Hello-World" }

  describe "#build!" do

    subject { super().build! }

    before :each do
      allow(repo).to receive(:clone)
      allow(repo).to receive(:update)
      allow(Dir).to receive(:chdir) { |&block| block.call }
      allow(Kernel).to receive(:exec)
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
        .with(["bundle", "install"])
        .ordered

      expect(Kernel).to have_received(:exec)
        .with(["bundle", "exec", "jekyll", "build"])
        .ordered
    end
  end

end
