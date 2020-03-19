module Ruby
  module Pomodoro
    module Tasks
      class Resource
        class << self
          extend Forwardable

          delegate size: :store

          def create(attributes)
            id = store.size.next
            Entity.new(id: id, **attributes.slice(:name, :spent_time)).tap do |task|
              store[id] = task
            end
          end

          def find(id)
            store[id]
          end

          def all
            store.values
          end

          def delete_all
            store.clear
          end

          def sum(attribute)
            all.inject(0) { |sum, task| sum + task.public_send(attribute).to_i }
          end

          private

          def store
            @store ||= {}
          end
        end
      end
    end
  end
end
