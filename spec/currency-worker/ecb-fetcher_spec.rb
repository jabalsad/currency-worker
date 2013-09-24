module CurrencyWorker
  describe DailyECBFetcher do
    let (:fetcher) { described_class.new }
    let (:date) { Date.parse("2013-09-20") }
    let (:fixture) do
      fixture_path = File.join(File.dirname(__FILE__), "ecb-fetcher-data.xml")
      File.read(fixture_path)
    end

    context "when retrieving currency data" do

      it "should return the data in a well-known format" do
        expect(RestClient).to receive(:get).and_return(fixture)
        rates = fetcher.fetch(date)

        # Just verify a few of them
        expect(rates.keys).to include("USD","JPY","GBP")
        expect(rates["USD"]).to eq("1.3514")
      end

      it "should ensure the xml version is correct" do
        wrong_version = fixture.gsub(/2002-08-01/,"2010-01-01")
        expect(RestClient).to receive(:get).and_return(wrong_version)
        expect {fetcher.fetch(date)}.to raise_error
      end

      it "should ensure the xml data is not empty" do
        expect(RestClient).to receive(:get).and_return(nil)
        expect {fetcher.fetch(date)}.to raise_error
      end

      it "should retry the service call when timing out" do
        expect(RestClient).to receive(:get).and_raise(Errno::ETIMEDOUT).and_return(fixture)
        expect(fetcher.fetch(date)).to include("USD")
      end

      it "should take the closest matching previous date if the requested date is not present" do
        expect(RestClient).to receive(:get).and_return(fixture)
        expect(fetcher.fetch(date.next)).to include("USD")
      end
    end
  end
end