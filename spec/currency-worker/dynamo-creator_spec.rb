module CurrencyWorker
  describe DynamoCreator do

    let (:dynamo) { double("dynamo-db") }
    let (:tables) { double("table-collection") }
    let (:table) { double("table") }
    let (:creator) { described_class.new(dynamo) }
    let (:config) do
      OpenStruct.new.tap do |o|
        o.table_name = "test-table"
        o.read_capacity = 1
        o.write_capacity = 1
      end
    end

    before (:each) do 
      dynamo.stub(:tables).and_return(tables)
      Retries.sleep_enabled = false
    end

    context "when retrieving the dynamo table" do
      it "should create the table if it does not exist" do
        expect(tables).to receive(:[]).with(config.table_name).and_return(table)
        expect(table).to receive(:exists?).and_return(false)
        expect(tables).to receive(:create).and_return(table)
        expect(table).to receive(:status).and_return(:creating,:active)
        expect(table).to receive(:load_schema)
        expect(creator.get_table(config)).to eq(table)
      end
    end

  end
end