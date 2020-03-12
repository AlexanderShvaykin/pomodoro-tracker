module Ruby
  module Pomodoro
    class Progressbar
      DEFAULT_OUTPUT_STREAM = $stdout

      def initialize(steps_count:, output: nil)
        @steps = steps_count
        @completed_steps = 0
        @stream = output || DEFAULT_OUTPUT_STREAM
      end

      def start(text)
        @text = text
        print
      end

      def increment
        @completed_steps += 1
        print
      end

      private

      def print
        @stream.print "#{@text} [#{@completed_steps}/#{@steps}]" + "\r"
        @stream.flush
      end
    end
  end
end
