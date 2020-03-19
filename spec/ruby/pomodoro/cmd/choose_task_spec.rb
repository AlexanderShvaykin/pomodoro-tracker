RSpec.describe Ruby::Pomodoro::Cmd::ChooseTask do
  describe "#call", :stub_cmd_printer do
    subject(:run) { cmd.call }
    let(:prompt) { AppHelper::Prompt.new(task.id) }
    let(:worker) { Ruby::Pomodoro::Worker.instance }
    let(:task) { Ruby::Pomodoro::Tasks::Resource.create(name: "Foo") }
    let(:main_cmd) { Proc.new { :ok } }

    before do
      allow(Ruby::Pomodoro::Cmd::Main).to receive(:new).and_return(main_cmd)
      worker.stop
    end

    it "starts task and call main cmd", :aggregate_failures do
      expect(worker).to receive(:start).with(task)
      expect(main_cmd).to receive(:call)
      run
    end

    context "with exit" do
      let(:prompt) { AppHelper::Prompt.new(0) }

      it "doesn't start task and call main cmd", :aggregate_failures do
        expect(worker).not_to receive(:start)
        expect(main_cmd).to receive(:call)
        run
      end
    end

    context "when worker do task" do
      let(:worker) { Ruby::Pomodoro::Worker.instance }
      let(:current_task) { task }

      before do
        worker.pomodoro_size = 5
        worker.start(current_task)
      end

      it "pauses, stop and start selected task" do
        expect(worker).to receive(:pause).and_call_original
        expect(worker).to receive(:stop).and_call_original
        expect(worker).to receive(:start).with(task).and_call_original
        expect(main_cmd).to receive(:call)
        run
      end

      context "with another task" do
        let(:current_task) { Ruby::Pomodoro::Tasks::Resource.create(name: "Baz") }

        it "pauses, stop and start selected task" do
          expect(worker).to receive(:pause).and_call_original
          expect(worker).to receive(:stop).and_call_original
          expect(worker).to receive(:start).with(task).and_call_original
          expect(main_cmd).to receive(:call)
          run
        end
      end

      context "with exit" do
        let(:prompt) { AppHelper::Prompt.new(0) }

        it "pauses and resume selected task" do
          expect(worker).to receive(:pause).and_call_original
          expect(worker).not_to receive(:stop)
          expect(worker).not_to receive(:start)
          expect(worker).to receive(:resume).and_call_original
          expect(main_cmd).to receive(:call)
          run
        end
      end
    end
  end
end
