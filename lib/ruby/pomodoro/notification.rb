module Ruby
  module Pomodoro
    class Notification
      attr_reader :message

      # @param message [String] Message
      # @param channel [Object, Module] Channel to push message
      def initialize(message, channel)
        @message = message
        @channel = channel
      end

      # @param repeat_at [Integer] Time to repeat
      # @return [TrueClass]
      def notify(repeat_at = nil)
        @channel.call(message)
        repeat(repeat_at) if repeat_at
        true
      end

      # @return [TrueClass]
      def stop
        @thread&.kill
        true
      end

      private

      def repeat(time_at)
        @thread = Thread.new do
          loop do
            sleep time_at
            @channel.call(message)
          end
        end
      end
    end
  end
end
