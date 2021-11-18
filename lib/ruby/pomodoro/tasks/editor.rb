module Ruby
  module Pomodoro
    module Tasks
      class Editor
        attr_reader :tasks_repo, :editor, :file_path

        # @param [Array<Ruby::Pomodoro::Task>] tasks_repo
        # @param [String] file_path
        # @param editor [Class, Object] Editor with method open, for create and open file
        def initialize(tasks_repo: Resource, file_path: Ruby::Pomodoro.tasks_file_path, editor: TTY::Editor)
          @tasks_repo = tasks_repo
          @file_path = file_path
          @editor = editor
        end

        # Open editor and save tasks from tmp file to task_repo
        # @return [TrueClass]
        def edit
          save
          editor.open(file_path)
          create_tasks
          true
        end

        # save list to disc
        # @return [TrueClass]
        def save
          File.open(file_path, "w") do |f|
            if @tasks_repo.size > 0
              f.puts(@tasks_repo.all.map {|task| print_task(task) }.join("\n"))
            end
          end
          true
        end

        # Load tasks form file
        # @return [TrueClass]
        def load
          create_tasks
          true
        end

        private

        def read_tmp_file
          File.readlines(file_path)
        end

        def create_tasks
          tasks_repo.delete_all
          read_tmp_file.each do |line|
            next unless line

            name, time = line.split("|").compact.map {|l| l.chomp.strip }
            tasks_repo.create(name: name, spent_time: TimeConverter.to_seconds(time))
          end
        end

        def print_task(task)
          "#{task.name} | #{TimeConverter.to_format_string(task.spent_time)}"
        end
      end
    end
  end
end
