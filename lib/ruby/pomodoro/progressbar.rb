module Ruby
  module Pomodoro
    class Progressbar
      DEFAULT_OUTPUT_STREAM = $stdout

      def initialize(seconds:, output: nil)
        @all_seconds = seconds
        @spent_seconds = 0
        @stream = output || DEFAULT_OUTPUT_STREAM
      end

      def start(text)
        @text = text
        print
      end

      def increment
        @spent_seconds += 1
        print
      end

      private

      def print
        @stream.print " In progress: #{@text} [#{strftime}]" + "\r"
        @stream.flush
      end

      def strftime
        seconds = @all_seconds - @spent_seconds
        minutes = seconds / 60
        "#{minutes} m #{seconds - minutes * 60} s"
      end
    end
  end
end
