module CurrencyWorker
  describe Orchestrator do

    let (:orchestrator) { described_class.new }
    let (:date) { "2015-10-21" }
    let (:dynamo) { double("dynamo-db") }
    let (:creator) { double("dynamo-creator") }
    let (:writer) { double("dynamo-writer") }
    let (:fetcher) { double("fetcher") }
    let (:rates) do
      { 
        "USD" => "2.0000",
        "GBP" => "1.5000",
        "ZAR" => "20.0000",
      }
    end

    before (:each) do 
      AWS::DynamoDB.stub(:new).and_return(dynamo)
      DynamoCreator.stub(:new).and_return(creator)
      DynamoWriter.stub(:new).and_return(writer)
      Fetcher.stub(:new).and_return(fetcher)
    end

    context "when processing a date" do

      before (:each) do
        expect(creator).to receive(:get_table)
      end

      it "should not write entries when the date already exists" do
        expect(writer).to receive(:date_exists?).and_return(true)
        orchestrator.start(date)
      end

      it "should handle errors" do
        expect(writer).to receive(:date_exists?).and_return(false)
        expect(fetcher).to receive(:fetch).and_raise(StandardError)
        expect {orchestrator.start(date)}.to raise_error(SystemExit)
      end

      it "should create, fetch and write entries" do
        expect(writer).to receive(:date_exists?).and_return(false)
        expect(fetcher).to receive(:fetch).with(date).and_return(rates)
        expect(writer).to receive(:write).with(date, rates)
        orchestrator.start(date)
      end
    end

  end
end