module Ruby
  module Pomodoro
    module Cmd
      class ErrorHandler < Base
        def call(error)
          path = File.join(Dir.home, ".ruby-pomodoro", "log")
          Logger.new(path).error(error.message)
          print text: "Oops! Error! Detail info in the log file (~/.ruby-pomodoro/log)\n", color: :red
          prompt.keypress(
            "Press any key to continue, resumes automatically in 3 seconds ...", timeout: 3
          )
          Main.new.call
        end
      end
    end
  end
end
