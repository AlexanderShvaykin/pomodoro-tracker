RSpec.describe Ruby::Pomodoro::Progressbar do
  subject(:bar) { described_class.new(seconds: 120, printer: printer) }
  let(:printer) { Ruby::Pomodoro::Printer.new(stream: stream, cursor: cursor, palette: palette) }
  let(:stream) { AppHelper::TestStream.new }
  let(:cursor) { AppHelper::TestCursor }
  let(:palette) { AppHelper::TestPalette }

  it "print messages", :aggregate_failures do
    bar.start("Foo")
    expect(stream).to receive(:flush).twice
    2.times { bar.increment }
    expect(stream.buff).to eq ["green  In progress: Foo [1 m 59 s]\r", "green  In progress: Foo [1 m 58 s]\r"]
  end
end
