RSpec.describe Ruby::Pomodoro::TasksEditor do
  let(:file_path) { "tmp/tasks" }
  let(:content) { ["Task1", "Task2"] }
  let(:test_editor) { AppHelper::TestEditor.new(content) }
  let(:tasks_repo) { [] }
  let(:task_editor) do
    described_class.new(file_path: file_path, editor: test_editor, tasks_repo: tasks_repo)
  end

  describe "#call" do
    it "creates new tasks", :aggregate_failures do
      expect { task_editor.call }.to change(tasks_repo, :size).by(2)
      expect(tasks_repo.map(&:name)).to eq(content)
      expect(task_editor.call).to eq true
    end

    context "with task" do
      let(:tasks_repo) { [Ruby::Pomodoro::Task.new("Foo")] }

      it "adds new tasks", :aggregate_failures do
        expect { task_editor.call }.to change(tasks_repo, :size).by(2)
        expect(tasks_repo.map(&:name)).to eq(["Foo", *content])
      end
    end

    context "with time spent" do
      let(:tasks_repo) { [Ruby::Pomodoro::Task.new("Foo", spent_time: 100)] }
      let(:names) { ["Task1", "Task2"] }
      let(:content) { ["#{names.first} | 2:h 40:m", "Task2 | 40:m"] }

      it "adds new tasks with spent time", :aggregate_failures do
        task_editor.call
        expect(tasks_repo.map(&:name)).to eq(["Foo", *names])
        expect(tasks_repo.map(&:spent_time)).to eq([100, 9600, 2400])
      end
    end
  end
end
