module AppHelper
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
end
