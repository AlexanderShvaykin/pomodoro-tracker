RSpec.describe Ruby::Pomodoro::TimeConverter do
  describe ".to_format_string" do
    it "format to string" do
      expect(described_class.to_format_string(9600)).to eq("2:h 40:m")
      expect(described_class.to_format_string(2400)).to eq("40:m")
    end
  end

  describe ".to_seconds" do
    it "format string to seconds" do
      expect(described_class.to_seconds("2:h 40:m")).to eq(9600)
      expect(described_class.to_seconds("40:m")).to eq(2400)
    end

    context "with invalid string" do
      it "format string to seconds" do
        expect(described_class.to_seconds("2:hours 40:m")).to eq(2400)
        expect(described_class.to_seconds("2:hours 40:min")).to eq(0)
        expect(described_class.to_seconds(nil)).to eq(0)
        expect(described_class.to_seconds("")).to eq(0)
        expect(described_class.to_seconds("Foo")).to eq(0)
      end
    end
  end
end
