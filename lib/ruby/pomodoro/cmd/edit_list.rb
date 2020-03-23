module Ruby
  module Pomodoro
    module Cmd
      class EditList < Base
        def call(editor)
          print
          worker.stop
          editor.save
          editor.edit
          Main.new.call
        end
      end
    end
  end
end
