shared_examples "clear terminal" do
  it "print clear terminal commands" do
    run
    expect(stream.buff[0..1]). to eq ["UP 100", "CLEAR_SCREEN_DOWN"]
  end
end
