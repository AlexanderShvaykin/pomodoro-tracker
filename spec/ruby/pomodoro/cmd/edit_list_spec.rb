RSpec.describe Ruby::Pomodoro::Cmd::EditList do
  describe "#call", :stub_cmd_printer do
    subject(:run) { cmd.call(editor) }

    let(:worker) { Ruby::Pomodoro::Worker.instance }
    let(:editor) { instance_double(Ruby::Pomodoro::Tasks::Editor, edit: true, save: true) }
    let(:main_cmd) { Proc.new { :ok } }
    let(:task) { Ruby::Pomodoro::Tasks::Resource.create(name: "Foo") }

    before do
      allow(Ruby::Pomodoro::Cmd::Main).to receive(:new).and_return(main_cmd)
      worker.stop
    end

    it_behaves_like "clear terminal"

    it "starts editor save and edit, and call main cmd", :aggregate_failures do
      expect(worker).to receive(:stop)
      expect(editor).to receive(:save)
      expect(editor).to receive(:edit)
      expect(main_cmd).to receive(:call)
      run
    end
  end
end
