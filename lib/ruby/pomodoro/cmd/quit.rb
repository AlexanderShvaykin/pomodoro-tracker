module Ruby
  module Pomodoro
    module Cmd
      # Save tasks and stop program
      class Quit < Base
        # @param [Ruby::Pomodoro::Tasks::Editor] editor
        # @return [Symbol]
        def call(editor)
          worker.delete_observers
          worker.stop
          editor.save
          print :quit
          :quit
        end
      end
    end
  end
end
