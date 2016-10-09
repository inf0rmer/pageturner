describe Consumers::BuildRequests do

  subject { described_class.new }

  describe "#consume!" do

    subject do
      super().tap do |instance|
        instance.consume!
        Hivent::Signal.new("build:requested").emit(payload, version: 1)
      end
    end

    context "when a 'build:finished' event is triggered" do

      let(:repository_double) { double(Models::GitRepository) }
      let(:builder_double)    { double(Workers::Builder) }
      let(:payload) do
        {
          repository: "inf0rmer/inf0rmer.github.io"
        }
      end

      before :each do
        allow(Models::GitRepository).to receive(:new)
          .with("inf0rmer/inf0rmer.github.io")
          .and_return(repository_double)

        allow(Workers::Builder).to receive(:new)
          .with(repository_double)
          .and_return(builder_double)

        allow(builder_double).to receive(:build!)
      end

      it "builds that repository" do
        subject

        expect(builder_double).to have_received(:build!)
      end

    end

  end

end
