module Ruby
  module Pomodoro
    class NotificationObserver
      # @param stop [Ruby::Pomodoro::Notification]
      # @param pause [Ruby::Pomodoro::Notification]
      # @param time [Numeric] repeat notifications interval in seconds
      def initialize(stop:, pause:, time:)
        @stop_notification = stop
        @pause_notification = pause
        @time = time
      end

      # @param [Symbol] event
      def update(event)
        case event
        when :finish
          @stop_notification.notify(@time)
          print TTY::Cursor.clear_line
          print "_Task #{Worker.instance.current_task.name} was stopped, type [\u21e7 + R] for resume\r"
        when :pause
          @pause_notification.notify(@time, skip_now: true)
        when :stop, :start
          @pause_notification.stop
          @stop_notification.stop
        else
          @pause_notification.stop
        end
      end
    end
  end
end
