require 'terminal-notifier'
require 'observer'
require 'tty-cursor'
require 'tty-editor'
require 'logger'
require 'aasm'
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
      def update(event)
        case event
        when :finish
          @stop_notification.notify(@time)
          print TTY::Cursor.clear_line
          print "_Task #{Worker.instance.current_task.name} was stopped, type [R] for resume\r"
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
        notify_ch = Ruby::Pomodoro::TerminalNotifierChannel
        @pause_notification = Ruby::Pomodoro::Notification.new("Task is paused, resume?", notify_ch)
        @stop_notification =
          Ruby::Pomodoro::Notification.new("Work is stopped, choose task for resume", notify_ch)
        @editor = Ruby::Pomodoro::TasksEditor.new(
          file_path: File.join(init_app_folder, "tasks"), tasks_repo: @tasks
        )
        @editor.load
        worker = Worker.instance

        worker.pomodoro_size = POMODORO_SIZE
        worker.add_observer(
          WorkerNotificationObserver.new(
            stop: @stop_notification, pause: @pause_notification, time: REPEAT_ALERT_TIME
          )
        )

        clear_terminal
        commands = <<~TEXT
          [c] - Choose task to work
          [e] - Edit list of tasks
          [p] - Pause work
          [r] - Resume work
          [s] - Stop work
          [q] - Quit
        TEXT

        loop do
          print "Total work time: "
          puts TimeConverter.to_format_string(@tasks.inject(0) {|sum, n| sum + n.spent_time})
          puts "List of tasks:"
          task_list
          puts
          if worker.paused?
            print "_ Task #{worker.current_task.name} was paused, type [r] for resume\r"
          else
            print commands
          end
          answer_handler(gets)
          clear_terminal
        rescue => e
          logger.error(e.message)
          clear_terminal
          puts "Oops! Error! Detail info in the log file (~/.ruby-pomodoro/log)"
          puts "Type any key for return"
          gets
          clear_terminal
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
        path
      end

      def answer_handler(answer)
        worker = Worker.instance
        clear_terminal
        case answer.to_s
        when 'q'
          finish_app
          abort "Bye!"
        when 'e'
          safe_action { @editor.edit }
        when 's'
          @pause_notification.stop
          worker.stop
        when 'c'
          safe_action { choose_task }
        when 'p'
          worker.pause if worker.working?
        when 'r'
          worker.resume if worker.paused?
        when "z"
          true
        when "R"
          task = worker.current_task
          worker.start(task) if task
        else
          false
        end.tap { @stop_notification.stop }
      end

      def safe_action
        changed = false
        worker = Worker.instance
        if worker.working?
          changed = true
          worker.pause
        end
        yield
        worker.resume if changed && worker.paused?
      end

      def choose_task
        task_list
        puts
        puts "Type number task, type z for return to menu"
        answer = gets
        return if answer_handler(answer)

        task = @tasks[answer.to_i]
        if task && answer =~ /[0-9]+/
          answer_handler('s')
          Worker.instance.start(task)
        else
          choose_task
        end
      end

      def task_list
        @tasks.each.with_index { |t, i| puts "#{i}. #{t.name} | #{format_time(t.spent_time)}" }
      end

      def gets
        STDIN.gets.chomp
      end

      def finish_app
        worker = Worker.instance
        @pause_notification.stop
        @stop_notification.stop
        worker.delete_observers
        worker.stop
        @editor.save
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
