module Ruby
  module Pomodoro
    module TimeHelpers
      # @param [Integer] seconds
      # @return [String] as N:d N:h N:m
      def to_format_string(seconds)
        Ruby::Pomodoro::TimeConverter.to_format_string(seconds)
      end
    end
  end
end
