module Ruby
  module Pomodoro
    module Cmd
      class Pause < Base
        def call
          if worker.working?
            Main.new.call
            worker.pause
            choices = [
              { key: 'y', name: "Resume this task", value: true },
              { key: 'n', name: 'Stop this task', value: false },
            ]
            print text: "#{worker.current_task.name} was paused\n", color: :yellow, clear: false
            if prompt.expand("Resume?", choices)
              Main.new.call
              worker.resume
            else
              Stop.new.call
            end
          else
            Main.new.call
          end
        end
      end
    end
  end
end
