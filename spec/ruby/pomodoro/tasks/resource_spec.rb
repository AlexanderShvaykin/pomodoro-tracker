RSpec.describe Ruby::Pomodoro::Tasks::Resource do
  let(:name) { "FOO" }
  let(:name2) { "Baz" }

  before { described_class.delete_all }

  describe ".create" do
    subject { described_class.create(name: name, spent_time: spent_time) }

    let(:spent_time) { 100 }

    it "creates task entity", :aggregate_failures do
      expect(subject.id).to eq 1
      expect(subject.name).to eq name
      expect(subject.spent_time).to eq spent_time
    end
  end

  describe ".sum" do
    before do
      described_class.create(name: name, spent_time: 10)
      described_class.create(name: name2, spent_time: 10)
    end

    it "returns sum as integer", :aggregate_failures do
      expect(described_class.sum(:spent_time)).to eq 20
      expect(described_class.sum(:name)).to eq 0
      expect(described_class.sum(:id)).to eq 3
    end
  end

  describe ".find" do
    it "returns task by id" do
      task = described_class.create(name: name)
      expect(described_class.find(task.id)).to eq task
    end

    it "returns nil if not found" do
      described_class.create(name: name)
      expect(described_class.find(100)).to eq nil
    end
  end

  describe ".all" do
    subject(:all_task) { described_class.all }

    before do
      described_class.create(name: name)
      described_class.create(name: name2)
    end

    it "returns all tasks", :aggregate_failures do
      expect(all_task.first.name).to eq name
      expect(all_task.last.name).to eq name2
    end
  end

  describe ".delete_all" do
    subject { described_class.delete_all }

    before do
      described_class.create(name: name)
      described_class.create(name: name2)
    end

    it "deletes all task" do
      expect { subject }.to change { described_class.all.size }.from(2).to(0)
    end
  end
end
