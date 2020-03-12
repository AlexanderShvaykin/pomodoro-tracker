RSpec.describe Ruby::Pomodoro::Progressbar do
  subject(:bar) { described_class.new(steps_count: 10, output: stream) }
  let(:stream) { AppHelper::TestStream.new }

  it "print messages", :aggregate_failures do
    bar.start("Foo")
    expect(stream).to receive(:flush)
    bar.increment
    expect(stream.buff).to eq ["Foo [0/10]\r", "Foo [1/10]\r"]
  end
end
