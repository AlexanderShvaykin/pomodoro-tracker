RSpec.describe Ruby::Pomodoro::Notification do
  let(:channel) { Proc.new {} }
  let(:message) { "Foo" }
  let(:notification) { described_class.new(message, channel) }

  describe "#notify" do
    subject(:notify) { notification.notify }

    specify do
      expect(channel).to receive(:call).with(message)
      notify
    end

    context "with repeat" do
      subject(:notify) { notification.notify(0.2) }

      specify do
        expect(channel).to receive(:call).with(message).twice
        notify
        sleep 0.3
      end
    end
  end

  describe "#stop" do
    it "stops repeat" do
      expect(channel).to receive(:call).with(message).twice
      notification.notify(0.2)
      sleep 0.3
      notification.stop
      sleep 0.2
    end
  end
end
