require 'terminal-notifier'
require 'observer'
require 'tty-cursor'
require 'tty-editor'
require 'tty-reader'
require 'logger'
require 'aasm'
require "erb"
require "ruby/pomodoro/command_controller"
require "ruby/pomodoro/notification_observer"
require "ruby/pomodoro/printer"
require "ruby/pomodoro/cmd/base"
require "ruby/pomodoro/cmd/main"
require "ruby/pomodoro/cmd/quit"
require "ruby/pomodoro/cmd/choose_task"
require "ruby/pomodoro/cmd/edit_list"
require "ruby/pomodoro/cmd/pause"
require "ruby/pomodoro/cmd/stop"
require "ruby/pomodoro/time_converter"
require "ruby/pomodoro/version"
require "ruby/pomodoro/tasks/resource"
require "ruby/pomodoro/tasks/editor"
require "ruby/pomodoro/task"
require "ruby/pomodoro/tasks/entity"
require "ruby/pomodoro/worker"
require "ruby/pomodoro/progressbar"
require "ruby/pomodoro/notification"
require "ruby/pomodoro/terminal_notifier_channel"

module Ruby
  module Pomodoro
    class Error < StandardError; end

    REPEAT_ALERT_TIME = 60 * 5
    POMODORO_SIZE = 60 * 30

    class << self
      attr_reader :editor

      def start
        Worker.instance.then do |worker|
          add_observer(worker)
          worker.pomodoro_size = POMODORO_SIZE
        end

        @editor = Tasks::Editor.new(
          file_path: File.join(init_app_folder, "tasks")
        )
        editor.load
        Cmd::Main.new.call
        reader = TTY::Reader.new
        reader.subscribe(CommandController)
        loop do
          reader.read_char
        rescue => e
          puts e.message
        end
      end

      private

      def add_observer(worker)
        notify_ch = TerminalNotifierChannel
        pause_notification = Notification.new("Task is paused, resume?", notify_ch)
        stop_notification =
          Notification.new("Work is stopped, choose task for resume", notify_ch)

        worker.add_observer(
          NotificationObserver.new(
            stop: stop_notification, pause: pause_notification, time: REPEAT_ALERT_TIME
          )
        )
      end

      def init_app_folder
        path = File.join(Dir.home, ".ruby-pomodoro")
        unless Dir.exists?(path)
          Dir.mkdir(path)
        end
        path
      end
    end
  end
end
