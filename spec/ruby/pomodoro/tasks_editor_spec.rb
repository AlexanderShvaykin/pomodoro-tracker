RSpec.describe Ruby::Pomodoro::TasksEditor do
  let(:file_path) { "tmp/tasks" }
  let(:content) { ["Task1", "Task2"] }
  let(:test_editor) { AppHelper::TestEditor.new(content) }
  let(:tasks_repo) { [] }
  let(:task_editor) do
    described_class.new(file_path: file_path, editor: test_editor, tasks_repo: tasks_repo)
  end

  before do
    unless Dir.exists?('tmp')
      Dir.mkdir("tmp")
    end
  end

  describe "#edit" do
    it "creates new tasks", :aggregate_failures do
      expect { task_editor.edit }.to change(tasks_repo, :size).by(2)
      expect(tasks_repo.map(&:name)).to eq(content)
      expect(task_editor.edit).to eq true
    end

    context "with task" do
      let(:tasks_repo) { [Ruby::Pomodoro::Task.new("Foo")] }

      it "adds new tasks", :aggregate_failures do
        expect { task_editor.edit }.to change(tasks_repo, :size).by(2)
        expect(tasks_repo.map(&:name)).to eq(["Foo", *content])
      end
    end

    context "with time spent" do
      let(:tasks_repo) { [Ruby::Pomodoro::Task.new("Foo", spent_time: 100)] }
      let(:names) { ["Task1", "Task2"] }
      let(:content) { ["#{names.first} | 2:h 40:m", "Task2 | 40:m"] }

      it "adds new tasks with spent time", :aggregate_failures do
        task_editor.edit
        expect(tasks_repo.map(&:name)).to eq(["Foo", *names])
        expect(tasks_repo.map(&:spent_time)).to eq([60, 9600, 2400])
      end
    end
  end

  describe "#save" do
    let(:tasks_repo) { [Ruby::Pomodoro::Task.new("Foo", spent_time: 100)] }

    it "adds new tasks with spent time", :aggregate_failures do
      task_editor.save
      expect(File.read(file_path)).to eq("Foo | 1:m")
    end
  end

  describe "#load" do
    let(:tasks_repo) { [Ruby::Pomodoro::Task.new("Foo", spent_time: 100)] }

    before { task_editor.save }

    it "loads tasks" do
      tasks_repo.clear
      expect { task_editor.load }.to change(tasks_repo, :size).by(1)
    end
  end
end
