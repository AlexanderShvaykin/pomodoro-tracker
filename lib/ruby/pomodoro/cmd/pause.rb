module Ruby
  module Pomodoro
    module Cmd
      class Pause < Base
        def call
          if worker.working?
            print
            worker.pause
            choices = [
              { key: 'y', name: "Resume this task", value: true },
              { key: 'n', name: 'Stop this task', value: false },
            ]
            if prompt.expand("Resume? #{worker.current_task.name}", choices)
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
