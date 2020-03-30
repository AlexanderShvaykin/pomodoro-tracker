# Commands for each user action
module Ruby
  module Pomodoro
    module Cmd
      class Base
        include TimeHelpers

        # @param [Ruby::Pomodoro::Printer] printer
        # @param prompt [Object]
        def initialize(printer: Ruby::Pomodoro::Printer.new, prompt: TTY::Prompt.new, worker: Ruby::Pomodoro::Worker.instance)
          @printer = printer
          @prompt  = prompt
          @worker  = worker
        end

        # @abstract
        # @return [Symbol, NilClass]
        def call; end

        private

        attr_reader :prompt, :worker

        def print(clear: true, **options)
          @printer.clear_terminal if clear

          type, value = options.first
          case type
          when :template
            @printer.print_template(value, binding)
          when :text
            @printer.print(value, color: options[:color])
          else
            nil
          end
        end
      end
    end
  end
end
