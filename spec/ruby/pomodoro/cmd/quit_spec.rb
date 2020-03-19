RSpec.describe Ruby::Pomodoro::Cmd::Quit do
  describe "#call", :stub_cmd_printer do
    subject(:run) { cmd.call(editor) }

    let(:worker) { instance_double(Ruby::Pomodoro::Worker) }
    let(:editor) { instance_double(Ruby::Pomodoro::Tasks::Editor) }

    it "sends stop and save and quit signal", :aggregate_failures do
      expect(worker).to receive(:stop)
      expect(worker).to receive(:delete_observers)
      expect(editor).to receive(:save)
      expect(run).to eq :quit
      expect(stream.buff.last).to eq "Bye!\n"
    end
  end
end
