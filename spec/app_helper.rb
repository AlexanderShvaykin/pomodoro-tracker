module AppHelper
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

    def open(path, content: "")
      File.open(path, "w") do |file|
        file.puts(content) unless content.empty?
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
