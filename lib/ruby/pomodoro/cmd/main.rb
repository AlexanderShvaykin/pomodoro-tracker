module Ruby
  module Pomodoro
    # Print tasks list and commands list
    module Cmd
      class Main < Base
        # @return [Symbol] signal for controller
        def call
          @tasks = Ruby::Pomodoro::Tasks::Resource.all
          print template: :main
          :ok
        end
      end
    end
  end
end
