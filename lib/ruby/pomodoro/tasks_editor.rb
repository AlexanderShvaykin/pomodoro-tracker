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
      def edit
        initial_content = @tasks_repo.map {|task| print_task(task) }.join("\n")
        editor.open(file_path, content: initial_content)
        content = read_file
        create_tasks(content)
        true
      end

      # save list to disc
      # @param [String] path_to_file
      def save(path_to_file)
        File.open(path_to_file, "w") do |f|
          f << @tasks_repo.map {|task| print_task(task) }.join("\n")
        end
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
          next unless line

          name, time = line.split("|").compact.map {|l| l.chomp.strip }
          tasks_repo.push(Task.new(name, spent_time: TimeConverter.to_seconds(time)))
        end
      end

      def print_task(task)
        "#{task.name} | #{TimeConverter.to_format_string(task.spent_time)}"
      end
    end
  end
end
