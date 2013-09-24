module CurrencyWorker
  describe DynamoWriter do

    let (:table) { double("dynamo-table") }
    let (:writer) { described_class.new(table) }
    let (:date) { "2000-01-01" }
    let (:rates) do
      {
        "USD" => "1.0000",
        "GBP" => "2.0000",
        "JPY" => "100.00",
      }
    end

    before (:all) do
      Retries.sleep_enabled = false
    end

    context "when writing records" do
      it "should retry when failing" do
        expect(table).to receive(:batch_put).exactly(3).times.and_raise(StandardError)
        expect {writer.write(date, rates)}.to raise_error
      end

      it "should batch put all the items in the correct format" do
        expect(table).to receive(:batch_put).with([
          {:currency => "USD", :rate => rates["USD"], :date => date},
          {:currency => "GBP", :rate => rates["GBP"], :date => date},
          {:currency => "JPY", :rate => rates["JPY"], :date => date},])
        writer.write(date, rates)
      end
    end

    context "when checking whether a date contains records" do
      let (:items) { double("item-collection") }
      let (:result) { double("query-result") }

      before (:each) do
        table.stub(:items).and_return(items)
        expect(items).to receive(:query).with(:hash_value => date).and_return(result)
      end

      it "should return false if no records exist on that date" do
        expect(result).to receive(:count).and_return(0)
        expect(writer.date_exists?(date)).to be_false
      end

      it "should return true if records do exist on that date" do
        expect(result).to receive(:count).and_return(10)
        expect(writer.date_exists?(date)).to be_true
      end
    end
  end
end