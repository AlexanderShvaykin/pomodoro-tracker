RSpec.describe Ruby::Pomodoro::Tasks::Entity do
  subject(:task) { described_class.new(name: name) }
  let(:name) { "Foo task" }

  it "has name" do
    expect(task.name).to eq name
  end

  it "has spent_time" do
    expect(task.spent_time).to be_zero
  end

  it "has pomodors" do
    expect(task.pomodors).to be_zero
  end

  describe "#track_time" do
    subject { task.track(10) }

    it "changes spent_time" do
      expect { subject }.to change(task, :spent_time).by(10)
    end
  end

  describe "#add_pomodoro" do
    subject { task.add_pomodoro }

    it "changes spent_time" do
      expect { subject }.to change(task, :pomodors).by(1)
    end
  end
end
