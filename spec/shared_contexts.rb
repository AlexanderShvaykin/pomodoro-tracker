shared_context "with stub printer", stub_cmd_printer: true do
  let(:printer) { Ruby::Pomodoro::Printer.new(stream, cursor) }
  let(:stream) { AppHelper::TestStream.new }
  let(:cursor) { AppHelper::TestCursor }
  let(:prompt) { AppHelper::Prompt.new(answer) }
  let(:answer) { nil }
  let(:worker) { instance_double(Ruby::Pomodoro::Worker) }
  let(:cmd) { described_class.new(printer: printer, prompt: prompt, worker: worker) }
end
