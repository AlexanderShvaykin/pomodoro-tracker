module Ruby
  module Pomodoro
    module CommandController
      class << self
        def call(event)
          signal =
            case event.value
            when 'q'
              Cmd::Quit.new.call(Pomodoro.editor)
            when 'c'
              Cmd::ChooseTask.new.call
            when 'e'
              Cmd::EditList.new.call(Pomodoro.editor)
            when 'p'
              Cmd::Pause.new.call
            when 's'
              Cmd::Stop.new.call
            when 'R'
              Worker.instance.then do |worker|
                task = worker.current_task
                worker.start(task) if task
                Cmd::Main.new.call
              end
            else
              Cmd::Main.new.call
            end
          abort if signal == :quit
        end
        alias_method :keypress, :call
      end
    end
  end
end
