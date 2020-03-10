module Ruby
  module Pomodoro
    # Singleton for work with tasks in application
    module Worker
      class << self
        attr_accessor :time_interval

        # clear work, should be called before do next task
        # @return [TrueClass]
        def stop
          @in_progress = false
          @do&.kill
          true
        end

        # @param [Ruby::Pomodoro::Task] task
        # @return [Ruby::Pomodoro::Task]
        def do(task)
          raise Error if @in_progress
          @in_progress = true
          @do = Thread.new do
            loop do
            sleep time_interval
            task.track(time_interval)
            end
          end
          task
        end

        # @return [TrueClass, FalseClass]
        def in_progress?
          @in_progress || false
        end
      end
    end
  end
end
