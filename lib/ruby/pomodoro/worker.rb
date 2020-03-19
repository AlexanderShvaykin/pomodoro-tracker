module Ruby
  module Pomodoro
    # Singleton for work with tasks in application
    class Worker
      include Observable
      include AASM
      include Singleton

      attr_reader :current_task
      attr_accessor :time_interval, :pomodoro_size, :progressbar

      aasm do
        state :sleeping, initial: true
        state :working, :paused

        after_all_transitions :notify

        event :start, before: :changed do
          transitions from: :sleeping, to: :working, after: ->(task) { run_task(task) }
        end

        event :resume, before: :changed do
          transitions from: :paused, to: :working
        end

        event :pause, before: :changed do
          transitions from: :working, to: :paused
        end


        event :finish, before: :changed do
          after { @do&.kill }

          transitions from: :working, to: :sleeping
        end

        event :stop, before: :changed do
          after do
            @do&.kill
            @current_task = nil
          end

          transitions to: :sleeping
        end
      end

      private

      def notify
        notify_observers(aasm.current_event)
      end

      # @param [Ruby::Pomodoro::Task] task
      # @return [TrueClass]
      def run_task(task)
        raise Error, "Setup pomodoro_size" if pomodoro_size.nil?

        @current_task = task
        @do = Thread.new do
          progress = progressbar || Ruby::Pomodoro::Progressbar.new(seconds: pomodoro_size)
          progress.start(task.name)
          count = 0
          loop do
            seconds = time_interval || 1
            sleep seconds
            unless paused?
              task.track(seconds)
              count += seconds
              progress.increment
              finish if count >= pomodoro_size.to_i && working?
            end
          end
        end
        true
      end
    end
  end
end
