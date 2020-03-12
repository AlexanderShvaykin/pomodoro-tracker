RSpec.describe Ruby::Pomodoro::Progressbar do
  subject(:bar) { described_class.new(seconds: 120, output: stream) }
  let(:stream) { AppHelper::TestStream.new }

  it "print messages", :aggregate_failures do
    bar.start("Foo")
    expect(stream).to receive(:flush).twice
    2.times { bar.increment }
    expect(stream.buff).to eq ["Foo [2 m 0 s]\r", "Foo [1 m 59 s]\r", "Foo [1 m 58 s]\r"]
  end
end
