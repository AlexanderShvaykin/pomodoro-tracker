module AppHelper
  class TestPalette
    class << self
      def method_missing(method, text)
        "#{method} #{text}"
      end
    end
  end

  class TestCursor
    class << self
      def up(n)
        "UP #{n}"
      end

      def clear_screen_down
        "CLEAR_SCREEN_DOWN"
      end
    end
  end
  class TestStream
    attr_reader :buff

    def initialize
      @buff = []
    end

    def print(text)
      @buff << text
    end

    def flush; end
  end

  module ProgressBar
    class << self
      def start(*); end
      def increment(*); end
    end

  end

  class TestEditor
    def initialize(content)
      @content = content
    end

    def open(path)
      File.open(path, "a") do |file|
        @content.each { |line| file.puts(line) }
      end
    end
  end

  class Prompt
    def initialize(answers)
      @answers = Array(answers)
    end

    def yes?(*)
      @answers.shift
    end

    def expand(*)
      @answers.shift
    end

    def select(*)
      @answers.shift
    end
  end
end
