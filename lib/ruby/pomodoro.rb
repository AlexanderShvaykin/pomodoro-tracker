require 'terminal-notifier'
require 'observer'
require 'tty-cursor'
require 'tty-editor'
require 'logger'
require "ruby/pomodoro/time_converter"
require "ruby/pomodoro/version"
require "ruby/pomodoro/tasks_editor"
require "ruby/pomodoro/task"
require "ruby/pomodoro/worker"
require "ruby/pomodoro/progressbar"
require "ruby/pomodoro/notification"
require "ruby/pomodoro/terminal_notifier_channel"

module Ruby
  module Pomodoro
    class Error < StandardError; end
    class WorkerNotificationObserver
      # @param stop [Ruby::Pomodoro::Notification]
      # @param pause [Ruby::Pomodoro::Notification]
      # @param time [Numeric] repeat notifications interval in seconds
      def initialize(stop:, pause:, time:)
        @stop_notification = stop
        @pause_notification = pause
        @time = time
      end

      # @param [Symbol] state
      def update(state)
        case state
        when :stop
          @stop_notification.notify(@time)
        when :pause
          @pause_notification.notify(@time, skip_now: true)
        else
          @pause_notification.stop
        end
      end
    end

    REPEAT_ALERT_TIME = 60 * 5
    POMODORO_SIZE = 60 * 30

    class << self
      def start
        @tasks = []
        init_app_folder
        notify_ch = Ruby::Pomodoro::TerminalNotifierChannel
        @pause_notification = Ruby::Pomodoro::Notification.new("Task is paused, resume?", notify_ch)
        @stop_notification =
          Ruby::Pomodoro::Notification.new("Work is stopped, choose task for resume", notify_ch)
        @editor = Ruby::Pomodoro::TasksEditor.new(
          file_path: "/tmp/.ruby-pomodoro_tasks", tasks_repo: @tasks
        )

        Worker.pomodoro_size = POMODORO_SIZE
        Worker.add_observer(
          WorkerNotificationObserver.new(
            stop: @stop_notification, pause: @pause_notification, time: REPEAT_ALERT_TIME
          )
        )

        clear_terminal
        puts "Hi, your tasks:"
        puts "Count: #{@tasks.size}"
        task_list
        2.times { puts }
        commands = <<~TEXT
          [c] - Choose task to work
          [e] - Edit list of tasks
          [p] - Pause work
          [r] - Resume work
          [s] - Stop work
          [q] - Quit
        TEXT

        loop do
          if Worker.in_progress?
            puts "In progress #{@progress_task.name}"
            puts
          else
            puts "List of tasks:"
            task_list
            puts
          end
          print commands
          answer_handler(gets)
          clear_terminal
        rescue => e
          logger.error(e.message)
          puts "Oops! Error! Detail info in the log file (~/.ruby-pomodoro/log)"
        end
      end

      private

      def logger
        path = File.join(Dir.home, ".ruby-pomodoro", "log")
        @logger ||= Logger.new(path)
      end

      def init_app_folder
        path = File.join(Dir.home, ".ruby-pomodoro")
        unless Dir.exists?(path)
          Dir.mkdir(path)
        end
      end

      def answer_handler(answer)
        clear_terminal
        case answer.to_s.downcase
        when 'q'
          finish_app
          abort "Bye!"
        when 'e'
          @editor.edit
        when 's'
          Worker.stop
        when 'c'
          choose_task
        when 'p'
          Worker.pause
        when 'r'
          Worker.resume
        when "z"
          true
        else
          false
        end.tap { @stop_notification.stop }
      end

      def choose_task
        task_list
        puts
        puts "Type number task, type z for return to menu"
        answer = gets
        task = @tasks[answer.to_i]
        if task
          @progress_task = task
          Worker.do(task)
        else
          unless answer_handler(answer)
            puts "Sorry, task not found!"
            choose_task
          end
        end
      end

      def task_list
        @tasks.each.with_index { |t, i| puts "#{i}. #{t.name} | #{format_time(t.spent_time)}" }
      end

      def gets
        STDIN.gets.chomp
      end

      def finish_app
        @pause_notification.stop
        @stop_notification.stop
        Worker.delete_observers
        Worker.stop
      end

      def format_time(seconds)
        Ruby::Pomodoro::TimeConverter.to_format_string(seconds)
      end

      def clear_terminal
        print TTY::Cursor.up(100)
        print TTY::Cursor.clear_screen_down
      end
    end
  end
end
