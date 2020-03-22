module Ruby
  module Pomodoro
    module Cmd
      class ErrorHandler < Base
        def call(error)
          path = File.join(Dir.home, ".ruby-pomodoro", "log")
          Logger.new(path).error(error.message)
          print
          puts "Oops! Error! Detail info in the log file (~/.ruby-pomodoro/log)"
          puts "Type any key for return"
          gets
        end
      end
    end
  end
end
