module Ruby
  module Pomodoro
    # Singleton for work with tasks in application
    module Worker
      class << self
        attr_accessor :time_interval, :pomodoro_size

        # clear work, should be called before do next task
        # @return [TrueClass]
        def stop
          @in_progress = false
          @do&.kill
          true
        end

        # @return [TrueClass]
        def pause
          @do["pause"] = true
        end

        # @return [TrueClass]
        def resume
          @do["pause"] = false
          true
        end

        # @param [Ruby::Pomodoro::Task] task
        # @return [Ruby::Pomodoro::Task]
        def do(task)
          raise Error if @in_progress
          @in_progress = true
          @do = Thread.new do
            count = 0
            loop do
              seconds = time_interval || 1
              sleep seconds
              unless Thread.current["pause"]
                task.track(seconds)
                count += seconds
              end
              stop if count >= pomodoro_size
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
