module Ruby
  module Pomodoro
    module Cmd
      class EditList < Base
        def call(editor)
          print
          worker.pause if worker.working?
          editor.edit
          Main.new.call
          worker.resume if worker.paused?
        end
      end
    end
  end
end
