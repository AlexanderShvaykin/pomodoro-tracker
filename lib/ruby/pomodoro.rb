require "ruby/pomodoro/version"
require "ruby/pomodoro/task"
require "ruby/pomodoro/worker"
require "ruby/pomodoro/progressbar"

module Ruby
  module Pomodoro
    class Error < StandardError; end
    class << self
      def start
        @tasks = []

        task_list
        2.times { puts }
        commands = <<~TEXT
            [s] - Choose task
            [a] - Add task
            [p] - Pause work
            [q] - Quit
        TEXT

        loop do
          puts commands
          answer_handler(gets)
        end
      end

      private

      def answer_handler(answer)
        2.times { puts }
        case answer.to_s.downcase
        when 'q'
          abort "Bye!"
        when 'a'
          add_task
        else
          answer
        end
      end

      def task_list
        puts "Hi, your tasks:"
        puts "Count: #{@tasks.size}"
        @tasks.each.with_index { |t, i| puts "#{i}. #{t.name}" }
      end

      def add_task
        puts "New task, type name and enter"
        print "Name: "
        @tasks << Task.new(gets)
        2.times { puts }
        task_list
        2.times { puts }
      end

      def gets
        STDIN.gets.chomp
      end

      def notify(message, time)
        Thread.new do
          loop do
            sleep time
            `say #{message}`
          end
        end
      end
    end
  end
end
