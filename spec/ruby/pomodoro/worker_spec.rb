RSpec.describe Ruby::Pomodoro::Worker do
  let(:worker) { described_class.instance }
  let(:task) { Ruby::Pomodoro::Task.new("foo") }
  let(:progressbar) { AppHelper::ProgressBar }

  before do
    worker.time_interval = 1
    worker.pomodoro_size = 5
    worker.progressbar = progressbar
    worker.stop
  end

  after do
    worker.time_interval = 1
    worker.pomodoro_size = 5
    worker.delete_observers
  end

  describe "configure" do
    before do
      worker.time_interval = 0.5
      worker.pomodoro_size = 10
    end

    it "returns config values", :aggregate_failures do
      expect(worker.time_interval).to eq 0.5
      expect(worker.pomodoro_size).to eq 10
      expect(worker.progressbar).to eq progressbar
    end
  end

  describe "aasm" do
    it "have aasm schema", :aggregate_failures do
      expect(worker).to transition_from(:sleeping).to(:working).on_event(:start, :task)
      expect(worker).to transition_from(:working).to(:paused).on_event(:pause)
      expect(worker).to transition_from(:paused).to(:working).on_event(:resume)
      expect(worker).to transition_from(:working).to(:sleeping).on_event(:finish)
      expect(worker).to allow_transition_to(:sleeping)
    end
  end

  describe ".stop" do
    subject(:stop) { worker.stop }

    before { worker.start(task) }

    it "kills worker thread" do
      thread = Thread.list.find { |t| t.to_s.include?("pomodoro/worker.rb") }
      expect(thread.alive?).to eq(true)
      stop
      sleep 0.1
      expect(thread.alive?).to eq(false)
    end

    it 'calls observer' do
      observer = double("observer", update: true)
      worker.add_observer(observer)
      expect(observer).not_to receive(:update).with(:sleeping)
      worker.stop
      expect(observer).not_to receive(:update)
      worker.stop
    end
  end

  describe ".start" do
    subject(:do_task) { worker.start(task) }

    it "can't keep more than one task" do
      worker.start(task)
      expect { subject }.to raise_error(AASM::InvalidTransition)
    end

    it "tracks time and print progress", :aggregate_failures do
      expect(progressbar).to receive(:start).with(task.name)
      expect(progressbar).to receive(:increment).exactly(4).times
      worker.time_interval = 0.1
      expect { subject }.to change(worker, :current_task).to(task)
      sleep 0.5
      expect(task.spent_time).to be >= 0.4
    end

    context "with pomodoro_size setup" do
      it "tracks time" do
        worker.time_interval = 0.1
        worker.pomodoro_size = 0.2
        do_task
        sleep 0.5
        expect(task.spent_time).to be < 0.4
      end
    end
  end

  describe ".pause" do
    it "pauses work" do
      worker.time_interval = 0.1
      worker.start(task)
      sleep 0.1
      worker.pause
      sleep 0.5
      expect(task.spent_time).to be < 0.3
    end

    it "calls observer" do
      observer = double("observer", update: true)
      worker.add_observer(observer)
      expect(observer).to receive(:update).with(:start)
      worker.start(task)
      expect(observer).to receive(:update).with(:pause)
      worker.pause
      expect(observer).not_to receive(:update)
      expect { worker.pause }.to raise_error(AASM::InvalidTransition)
    end
  end

  describe ".resume" do
    it "pauses work" do
      worker.time_interval = 0.1
      worker.start(task)
      sleep 0.1
      worker.pause
      worker.resume
      sleep 0.5
      expect(task.spent_time).to be > 0.4
    end

    it 'calls observer' do
      observer = double("observer", update: true)
      worker.add_observer(observer)
      expect(observer).to receive(:update).with(:start)
      expect(observer).to receive(:update).with(:pause)
      expect(observer).to receive(:update).with(:resume)
      worker.start(task)
      worker.pause
      worker.resume
      expect(observer).not_to receive(:update)
      expect { worker.resume }.to raise_error(AASM::InvalidTransition)
    end
  end
end
