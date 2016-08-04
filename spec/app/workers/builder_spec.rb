describe Workers::Builder do
  let(:builder)   { described_class.new(repo) }
  let(:repo)      { instance_double("Models::GitRepository").as_null_object }
  let(:repo_name) { "octocat/Hello-World" }

  before :each do
    allow(repo).to receive(:name).and_return(repo_name)
  end

  describe "#build!" do
    subject { builder.build! }

    before :each do
      allow(repo).to receive(:clone)
      allow(repo).to receive(:update)

      allow(builder).to receive(:fork) do |&block|
        block.call
      end

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
        .with("bundle install && bundle exec jekyll build -d /sites/#{repo_name}")
    end

  end

end
