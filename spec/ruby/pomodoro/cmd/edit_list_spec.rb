RSpec.describe Ruby::Pomodoro::Cmd::EditList do
  describe "#call", :stub_cmd_printer do
    subject(:run) { cmd.call(editor) }

    let(:worker) { Ruby::Pomodoro::Worker.instance }
    let(:editor) { instance_double(Ruby::Pomodoro::Tasks::Editor, edit: true) }
    let(:main_cmd) { Proc.new { :ok } }
    let(:task) { Ruby::Pomodoro::Tasks::Resource.create(name: "Foo") }

    before do
      allow(Ruby::Pomodoro::Cmd::Main).to receive(:new).and_return(main_cmd)
      worker.stop
    end

    it_behaves_like "clear terminal"

    it "starts editor and call main cmd", :aggregate_failures do
      expect(worker).not_to receive(:pause)
      expect(editor).to receive(:edit)
      expect(main_cmd).to receive(:call)
      run
    end

    context "when worker do task" do
      let(:worker) { Ruby::Pomodoro::Worker.instance }
      let(:current_task) { task }

      before do
        worker.pomodoro_size = 5
        worker.start(current_task)
      end

      it "pauses and resume worker" do
        expect(worker).to receive(:pause).and_call_original
        expect(editor).to receive(:edit)
        expect(main_cmd).to receive(:call)
        expect(worker).to receive(:resume).and_call_original
        run
      end
    end
  end
end
