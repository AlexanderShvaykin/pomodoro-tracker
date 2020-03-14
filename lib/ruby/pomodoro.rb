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
    class WorkerNotification
      TIME = 60 * 5

      # @param stop [Ruby::Pomodoro::Notification]
      # @param pause [Ruby::Pomodoro::Notification]
      def initialize(stop:, pause:)
        @stop_notification = stop
        @pause_notification = pause
      end

      def update(state)
        case state
        when :stop
          @stop_notification.notify(TIME)
        when :pause
          @pause_notification.notify(TIME)
        else
          @pause_notification.stop
        end
      end
    end

    class << self
      def start
        notify_ch = Ruby::Pomodoro::TerminalNotifierChannel
        @pause_notification = Ruby::Pomodoro::Notification.new("Task is paused, resume?", notify_ch)
        @stop_notification =
          Ruby::Pomodoro::Notification.new("Work is stopped, choose task for resume", notify_ch)

        Worker.pomodoro_size = 60 * 30
        Worker.add_observer(
          WorkerNotification.new(stop: @stop_notification, pause: @pause_notification)
        )
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
        when 'r'
          Worker.resume
        else
          answer
        end
        @stop_notification.stop
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

      def finish_app
        @pause_notification.stop
        @stop_notification.stop
        Worker.stop
      end
    end
  end
end
