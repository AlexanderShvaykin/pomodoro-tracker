module Ruby
  module Pomodoro
    module CommandController
      class << self
        def call(event)
          signal =
            case event.value
            when 'q', 'й'
              Cmd::Quit.new.call(Pomodoro.editor)
            when 'c', 'с'
              Cmd::ChooseTask.new.call
            when 'e', 'у'
              Cmd::EditList.new.call(Pomodoro.editor)
            when 'p', 'з'
              Cmd::Pause.new.call
            when 's', 'ы'
              Cmd::Stop.new.call
            when 'R', 'К'
              Worker.instance.then do |worker|
                task = worker.current_task
                worker.start(task) if task
                Cmd::Main.new.call
              end
            when /[1-9]/
              Worker.instance.then do |worker|
                task = Ruby::Pomodoro::Tasks::Resource.find(event.value.to_i)
                return if task.nil? || task.id == worker.current_task&.id

                Cmd::Main.new.call
                worker.stop
                worker.start(task)
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
