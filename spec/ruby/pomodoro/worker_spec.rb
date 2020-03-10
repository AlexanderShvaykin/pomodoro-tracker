RSpec.describe Ruby::Pomodoro::Worker do
  let(:worker) { described_class }
  let(:task) { Ruby::Pomodoro::Task.new("foo") }

  after do
    worker.stop
  end

  describe "configure" do
    before do
      worker.time_interval = 0.5
    end

    it "returns config values", :aggregate_failures do
      expect(worker.time_interval).to eq 0.5
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

    it "tracks time" do
      worker.time_interval = 0.1
      do_task
      sleep 0.5
      expect(task.spent_time).to be >= 0.4
    end
  end
end
