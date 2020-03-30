RSpec.describe Ruby::Pomodoro::Printer do
  let(:printer) { described_class.new(stream: stream, cursor: cursor, palette: palette) }
  let(:stream) { AppHelper::TestStream.new }
  let(:cursor) { AppHelper::TestCursor }
  let(:palette) { AppHelper::TestPalette }
  let(:name) { "Test name" }

  describe "#print_template" do
    subject { printer.print_template("spec/fixtures/test.txt.erb", binding) }

    it "prints template with binding" do
      expect { subject }.to change(stream, :buff).to(["#{name} Test\n"])
    end
  end

  describe "#clear_terminal" do
    subject { printer.clear_terminal }

    it "prints template with binding" do
      expect { subject }.to change(stream, :buff).to(["UP 100", "CLEAR_SCREEN_DOWN"])
    end
  end

  describe "#print" do
    subject { printer.print("message", color: color) }

    let(:color) { nil }

    it "prints template with binding" do
      expect { subject }.to change(stream, :buff).to(["message"])
    end

    context "with color" do
      let(:color) { "green" }

      it "prints template with binding" do
        expect { subject }.to change(stream, :buff).to(["green message"])
      end
    end
  end
end
