module Ruby
  module Pomodoro
    class Printer
      def initialize(stream: $stdout, cursor: TTY::Cursor, palette: Pastel.new)
        @stream = stream
        @cursor = cursor
        @palette = palette
      end

      def print_template(template_name, cmd_binding)
        @__cmd_binding = cmd_binding
        stream.print(render(template_name))
      end

      def clear_terminal
        stream.print(cursor.up(100))
        stream.print(cursor.clear_screen_down)
      end

      def print(text, color: nil)
        if color
          stream.print(palette.send(color, text))
        else
          stream.print(text)
        end
        stream.flush
      end

      def print_line(*args)
        cursor.clear_line
        print(*args)
      end


      def render(file_name)
        ERB.new(read_file(file_name)).result(@__cmd_binding)
      end

      private

      attr_reader :stream, :cursor, :palette


      def read_file(file_name_or_path)
        if file_name_or_path.kind_of?(Symbol)
          path = File.expand_path(
            "../../../#{File.join("view", "#{file_name_or_path}.txt.erb")}", __FILE__
          )
          File.read(path)
        else
          File.read(file_name_or_path)
        end
      end
    end
  end
end
