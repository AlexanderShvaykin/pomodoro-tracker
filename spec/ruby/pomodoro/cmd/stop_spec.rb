RSpec.describe Ruby::Pomodoro::Cmd::Stop do
  describe "#call", :stub_cmd_printer do
    subject(:run) { cmd.call }

    let(:worker) do
      instance_double(Ruby::Pomodoro::Worker, stop: true, sleeping?: true)
    end
    let(:main_cmd) { Proc.new { :ok } }

    before do
      allow(Ruby::Pomodoro::Cmd::Main).to receive(:new).and_return(main_cmd)
      worker.stop
    end

    it "runs main cmd" do
      expect(worker).to receive(:stop)
      expect(main_cmd).to receive(:call)
      run
    end

    context "with do task" do
      let(:worker) do
        instance_double(Ruby::Pomodoro::Worker, stop: true, sleeping?: false)
      end

      it "pauses worker" do
        expect(worker).to receive(:stop)
        expect(main_cmd).to receive(:call)
        run
      end
    end
  end
end
