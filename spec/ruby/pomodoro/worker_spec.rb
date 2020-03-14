RSpec.describe Ruby::Pomodoro::Worker do
  let(:worker) { described_class }
  let(:task) { Ruby::Pomodoro::Task.new("foo") }
  let(:progressbar) { instance_double(Ruby::Pomodoro::Progressbar, increment: nil, start: nil) }

  before do
    worker.time_interval = 1
    worker.pomodoro_size = 5
    worker.progressbar = progressbar
  end

  after do
    worker.stop
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

  describe ".stop" do
    subject(:stop) { worker.stop }

    before { worker.do(task) }

    it "kills worker thread" do
      thread = Thread.list.find { |t| t.to_s.include?("pomodoro/worker.rb") }
      expect(thread.alive?).to eq(true)
      stop
      sleep 0.1
      expect(thread.alive?).to eq(false)
    end

    it "changes in_progress" do
      expect { subject }.to change(worker, :in_progress?).to(false)
    end

    it 'calls observer' do
      observer = double("observer", update: true)
      worker.add_observer(observer)
      expect(observer).to receive(:update).with(:stop)
      worker.stop
    end
  end

  describe ".do" do
    subject(:do_task) { worker.do(task) }

    it "returns task" do
      expect(subject).to eq(task)
    end

    it "can't keep more than one task" do
      worker.do(task)
      expect { subject }.to raise_error(Ruby::Pomodoro::Error)
    end

    it "tracks time and print progress", :aggregate_failures do
      expect(progressbar).to receive(:start).with(task.name)
      expect(progressbar).to receive(:increment)
      worker.time_interval = 0.1
      do_task
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
      worker.do(task)
      sleep 0.1
      worker.pause
      sleep 0.5
      expect(task.spent_time).to be < 0.3
    end

    it "calls observer" do
      observer = double("observer", update: true)
      worker.add_observer(observer)
      expect(observer).to receive(:update).with(:pause)
      worker.do(task)
      worker.pause
    end
  end

  describe ".resume" do
    it "pauses work" do
      worker.time_interval = 0.1
      worker.do(task)
      sleep 0.1
      worker.pause
      worker.resume
      sleep 0.5
      expect(task.spent_time).to be > 0.4
    end

    it 'calls observer' do
      observer = double("observer", update: true)
      worker.add_observer(observer)
      expect(observer).to receive(:update).with(:resume)
      worker.do(task)
      worker.pause
      worker.resume
    end
  end
end
