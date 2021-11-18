RSpec.describe Ruby::Pomodoro::Tasks::Editor do
  let(:file_path) { "tmp/tasks" }
  let(:content) { ["Task1", "Task2"] }
  let(:test_editor) { AppHelper::TestEditor.new(content) }
  let(:tasks_repo) { Ruby::Pomodoro::Tasks::Resource }
  let(:task_editor) do
    described_class.new(file_path: file_path, editor: test_editor, tasks_repo: tasks_repo)
  end

  before do
    unless Dir.exists?('tmp')
      Dir.mkdir("tmp")
    end
    File.delete(file_path) if File.exist?(file_path)
    tasks_repo.delete_all
  end

  after do
    File.delete(file_path) if File.exist?(file_path)
  end

  describe "#edit" do
    subject { task_editor.edit }

    it "creates new tasks", :aggregate_failures do
      expect { subject }.to change(tasks_repo, :size).by(2)
      expect(tasks_repo.all.map(&:name)).to eq(content)
      expect(subject).to eq true
    end

    context "with task" do
      before do
        tasks_repo.create(name: "Foo")
      end

      it "adds new tasks", :aggregate_failures do
        expect { subject }.to change(tasks_repo, :size).by(2)
        expect(tasks_repo.all.map(&:name)).to eq(["Foo", *content])
      end
    end

    context "with time spent" do
      let(:names) { ["Task1", "Task2"] }
      let(:content) { ["#{names.first} | 2:h 40:m", "Task2 | 40:m"] }

      before do
        tasks_repo.create(name: "Foo", spent_time: 100)
      end

      it "adds new tasks with spent time", :aggregate_failures do
        task_editor.edit
        expect(tasks_repo.all.map(&:name)).to eq(["Foo", *names])
        expect(tasks_repo.all.map(&:spent_time)).to eq([60, 9600, 2400])
      end
    end
  end

  describe "#save" do
    before do
      tasks_repo.create(name: "Foo", spent_time: 100)
    end

    it "adds new tasks with spent time", :aggregate_failures do
      task_editor.save
      expect(File.read(file_path).chomp).to eq("Foo | 1:m")
    end
  end

  describe "#load" do
    before do
      tasks_repo.create(name: "Foo", spent_time: 100)
      task_editor.save
    end

    it "loads tasks" do
      tasks_repo.delete_all
      expect { task_editor.load }.to change(tasks_repo, :size).by(1)
    end
  end
end
