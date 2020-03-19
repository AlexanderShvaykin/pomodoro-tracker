module Ruby
  module Pomodoro
    module Cmd
      # Select task and start worker
      class ChooseTask < Base
        # @param [Ruby::Pomodoro::Worker] worker
        def call
          worker.pause if worker.working?
          print
          task = Ruby::Pomodoro::Tasks::Resource.find(select_task(worker.current_task))
          Main.new.call
          if task
            worker.stop
            worker.start(task)
          else
            worker.resume if worker.paused?
          end
          :ok
        end

        private

        def select_task(current_task)
          options = Ruby::Pomodoro::Tasks::Resource.all.map do |task|
            disable = task == current_task ? "(The task in progress)" : nil
            { value: task.id, name: task.name, disabled: disable }
          end
          prompt.select("Select task", [*options, { name: "exit", value: 0 }])
        end
      end
    end
  end
end
