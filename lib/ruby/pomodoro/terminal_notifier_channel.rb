module Ruby
  module Pomodoro
    module TerminalNotifierChannel
      module_function

      def call(message)
        TerminalNotifier.notify(
          message, title: "RubyPomodoro", sound: "default"
        )
      end
    end
  end
end
