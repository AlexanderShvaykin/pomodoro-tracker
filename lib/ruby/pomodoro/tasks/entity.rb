module Ruby
  module Pomodoro
    module Tasks
      class Entity
        attr_reader :name, :pomodors, :spent_time, :id

        def initialize(name:, spent_time: 0, id: nil)
          @name = name
          @spent_time = spent_time
          @pomodors = 0
          @id = id
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
end
