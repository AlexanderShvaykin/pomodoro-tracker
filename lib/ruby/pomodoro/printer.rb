module Ruby
  module Pomodoro
    class Printer
      def initialize(stream = $stdout, cursor = TTY::Cursor)
        @stream = stream
        @cursor = cursor
      end

      def print_template(template_name, cmd_binding)
        @__cmd_binding = cmd_binding
        clear_terminal
        stream.print(render(template_name)) if template_name
      end

      def render(file_name)
        ERB.new(read_file(file_name)).result(@__cmd_binding)
      end

      private

      attr_reader :stream, :cursor

      def clear_terminal
        stream.print(cursor.up(100))
        stream.print(cursor.clear_screen_down)
      end

      def read_file(file_name)
        path =
          File.expand_path("../../../#{File.join("view", "#{file_name}.txt.erb")}", __FILE__)
        File.read(path)
      end
    end
  end
end
