require 'terminal-notifier'
require 'observer'
require "ruby/pomodoro/version"
require "ruby/pomodoro/task"
require "ruby/pomodoro/worker"
require "ruby/pomodoro/progressbar"
require "ruby/pomodoro/notification"
require "ruby/pomodoro/terminal_notifier_channel"

module Ruby
  module Pomodoro
    class Error < StandardError; end
    PENDING_REPEAT_TIME = 60 * 5
    class << self
      def start
        @notification = build_notification
        @notification["stop"] = true
        Worker.pomodoro_size = 60 * 30
        @tasks = []

        puts "Hi, your tasks:"
        puts "Count: #{@tasks.size}"
        task_list
        2.times { puts }
        commands = <<~TEXT
          [c] - Choose task to work
          [a] - Add task
          [p] - Pause work
          [r] - Resume work
          [s] - Stop work
          [q] - Quit
        TEXT

        loop do
          puts commands
          2.times { puts }
          answer_handler(gets)
        end
      rescue
        finish_app
        abort "Sorry!"
      end

      private

      def answer_handler(answer)
        2.times { puts }
        puts answer
        case answer.to_s.downcase
        when 'q'
          finish_app
          abort "Bye!"
        when 'a'
          add_task
        when 's'
          Worker.stop
        when 'c'
          choose_task
        when 'p'
          Worker.pause
          notify("Resume?", PENDING_REPEAT_TIME)
        when 'r'
          @notification["stop"] = true
          Worker.resume
        else
          answer
        end
      end

      def choose_task
        task_list
        print "Type number task: "
        task = @tasks[gets.to_i]
        if task
          Worker.do(task)
        else
          puts "Sorry, task not found!"
          choose_task
        end
      end

      def task_list
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
        @notification["message"] = message
        @notification["time"] = time
        @notification["stop"] = false
      end

      def finish_app
        @notification.kill
        Worker.stop
      end

      def build_notification
        Thread.new do
          count = 0
          loop do
            message = Thread.current["message"]
            sleep 1
            count += 1 unless Thread.current["stop"]
            if count >= Thread.current["time"].to_i && message
              TerminalNotifier.notify(message, :title => 'RubyPomodoro', :sound => 'default')
              count = 0
            elsif Thread.current["stop"]
              count = 0
            end
          end
        end
      end
    end
  end
end
