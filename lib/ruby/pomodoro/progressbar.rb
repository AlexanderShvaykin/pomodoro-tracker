module Ruby
  module Pomodoro
    class Progressbar
      def initialize(seconds:, printer: Ruby::Pomodoro::Printer.new)
        @all_seconds = seconds
        @spent_seconds = 0
        @printer = printer
      end

      def start(text)
        @text = text
      end

      def increment
        @spent_seconds += 1
        print
      end

      private

      def print
        @printer.print " In progress: #{@text} [#{strftime}]\r", color: :green
      end

      def strftime
        seconds = @all_seconds - @spent_seconds
        minutes = seconds / 60
        "#{minutes} m #{seconds - minutes * 60} s"
      end
    end
  end
end
