module Ruby
  module Pomodoro
    module Cmd
      class Stop < Base
        def call
          worker.stop
          Main.new.call
        end
      end
    end
  end
end
