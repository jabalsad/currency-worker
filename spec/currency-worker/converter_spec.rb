module CurrencyWorker
  describe Converter do

    let (:converter) { described_class }
    let (:data) do
      {
        "USD" => "2.0000",
        "ZAR" => "10.0000",
      }
    end

    context "when converting currencies" do
      it "should contain the correct converted values" do
        converted = converter.convert(data, "EUR", "USD")
        expected = {
          "EUR" => "0.5000",
          "ZAR" => "5.0000",
        }
        expect(converted).to eq(expected)
      end
    end
  end
end