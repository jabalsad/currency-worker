module CurrencyWorker
  class DynamoWriter
    
    require "retries"

    include CurrencyWorker::Logger

    def initialize(table)
      @table = table
      @retry_opts = {
        :max_tries => 3,
        :base_sleep_seconds => 3,
        :max_sleep_seconds => 30,
        :rescue => StandardError
      }
    end

    def write(date, rates)
      with_error_handling do
        # 25 is the maximum allowed items in a batch put operation
        make_items(date, rates).each_slice(25) do |slice|
          with_retries(@retry_opts) do |attempt|
            log.debug "Attempting to write #{slice.size} records to dynamo, attempt=#{attempt}"
            @table.batch_put(slice)
          end
        end
      end
      log.info "Wrote #{rates.size} records to dynamo for date=#{date}"
    end

    def date_exists?(date)
      with_error_handling do
        with_retries(@retry_opts) do |attempt|
          log.debug "Attempting to check whether the records for #{date} has been written, attempt=#{attempt}"
          count = @table.items.query(:hash_value => date.to_s).count
          log.info "Found #{count} records matching date=#{date}"
          count > 0
        end
      end
    end

    private

    def with_error_handling(&block)
      begin
        yield
      rescue => e
        log.error "Error while performing dynamo work: #{e}"
        log.debug e.backtrace
        raise e
      end
    end

    def make_items(date, rates)
      [].tap do |items|
        rates.each do |currency, rate|
          items << {
            :currency => currency,
            :rate => rate,
            :date => date.to_s,
          }
        end
      end
    end

  end
end