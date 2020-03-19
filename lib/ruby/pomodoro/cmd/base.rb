# Commands for each user action
module Ruby
  module Pomodoro
    module Cmd
      class Base
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

        def print(template_name = nil)
          @printer.print_template(template_name, binding)
        end
      end
    end
  end
end
