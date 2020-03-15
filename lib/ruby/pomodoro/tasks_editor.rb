module Ruby
  module Pomodoro
    class TasksEditor
      attr_reader :tasks_repo, :editor, :file_path

      # @param [Array<Ruby::Pomodoro::Task>] tasks_repo
      # @param [String] file_path
      # @param editor [Class, Object] Editor with method open, for create and open file
      def initialize(tasks_repo:, file_path: "/tmp/.ruby-pomodoro-tasks", editor: TTY::Editor)
        @tasks_repo = tasks_repo
        @file_path = file_path
        @editor = editor
      end

      # Open editor and save tasks from tmp file to task_repo
      # @return [TrueClass]
      def call
        initial_content = @tasks_repo.map {|task| print_task(task) }.join("\n")
        editor.open(file_path, content: initial_content)
        content = read_file
        create_tasks(content)
        true
      end

      private

      def read_file
        file = File.new(file_path, "r")
        content =  file.readlines
        file.close
        File.delete(file)
        content
      end

      def create_tasks(content)
        tasks_repo.clear
        content.each do |line|
          tasks_repo.push(Task.new(line.chomp))
        end
      end

      def print_task(task)
        task.name
      end
    end
  end
end
