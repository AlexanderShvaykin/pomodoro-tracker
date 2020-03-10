module Ruby
  module Pomodoro
    # Task for [Ruby::Pomodoro::Worker]
    class Task
      attr_reader :name, :pomodors, :spent_time

      def initialize(name)
        @name = name
        @spent_time = @pomodors = 0
      end

      # @return [Integer]
      def add_pomodoro
        @pomodors += 1
      end

      # @param [Integer] seconds
      # @return [Integer]
      def track(seconds)
        @spent_time += seconds
      end
    end
  end
end
