RSpec.describe Ruby::Pomodoro::TerminalNotifierChannel do
  let(:message) { "Foo" }

  it "calls TerminalNotifier with message" do
    expect(TerminalNotifier)
      .to receive(:notify).with(message, :title => 'RubyPomodoro', :sound => 'default')
    described_class.call(message)
  end
end
