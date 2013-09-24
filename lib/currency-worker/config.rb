module CurrencyWorker
  class Config
    require "ostruct"

    def self.instance
      @instance ||= mk_config
    end

    def self.mk_config
      o = OpenStruct.new
      o.aws_region = "eu-west-1"

      o.dynamo = OpenStruct.new
      o.dynamo.table_name = "currency-rates-usd"
      o.dynamo.read_capacity = 10
      o.dynamo.write_capacity = 5

      o
    end
  end
end