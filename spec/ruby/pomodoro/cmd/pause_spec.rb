RSpec.describe Ruby::Pomodoro::Cmd::Pause do
  describe "#call", :stub_cmd_printer do
    subject(:run) { cmd.call }

    let(:worker) do
      instance_double(Ruby::Pomodoro::Worker, stop: true, working?: false)
    end
    let(:main_cmd) { Proc.new { :ok } }
    let(:task) { Ruby::Pomodoro::Tasks::Entity.new(name: "Foo") }

    before do
      allow(Ruby::Pomodoro::Cmd::Main).to receive(:new).and_return(main_cmd)
      worker.stop
    end

    it "runs main cmd" do
      expect(main_cmd).to receive(:call)
      run
    end

    context "with do task" do
      let(:worker) do
        instance_double(Ruby::Pomodoro::Worker, stop: true, working?: true, pause: true, current_task: task, resume: true)
      end
      let(:answer) { true }

      it_behaves_like "clear terminal"

      it "pauses worker" do
        expect(main_cmd).to receive(:call)
        expect(worker).to receive(:pause)
        expect(worker).to receive(:resume)
        run
      end
    end
  end
end
