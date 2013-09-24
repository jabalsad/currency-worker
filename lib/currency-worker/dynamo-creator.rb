module CurrencyWorker
  class DynamoCreator

    require "aws/dynamo_db"
    require "retries"

    include CurrencyWorker::Logger

    class TableNotReadyException < StandardError; end

    def initialize(dynamo)
      @dynamo = dynamo
    end

    def get_table(config)
      table = @dynamo.tables[config.table_name]
      create_table(config) unless table.exists?
      table.load_schema
      table
    end

    private

    def create_table(config)
      table = @dynamo.tables.create(
        config.table_name,
        config.read_capacity,
        config.write_capacity,
        { :hash_key => { :date => :string },
          :range_key => { :currency => :string } })
      log.info "Created dynamo table: #{config}"

      retry_opts = {
        :max_tries => 10,
        :base_sleep_seconds => 30,
        :max_sleep_seconds => 30,
        :rescue => TableNotReadyException,
      }
      with_retries(retry_opts) do |attempt|
        status = table.status
        log.debug "Table creation status=#{status}, attempt=#{attempt}"
        raise TableNotReadyException unless status == :active
      end
    end

  end
end