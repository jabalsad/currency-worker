module CurrencyWorker
  class Fetcher

    include CurrencyWorker::Logger
    include CurrencyWorker::DateHelper

    def fetch(date)
      data = choose_fetcher(date).fetch(date)
      usd_data = Converter.convert(data, ECBFetcher::BASE_CURRENCY, "USD")
      log.debug "Converted data for date=#{date} into USD: #{usd_data}"
      usd_data
    end

    private

    def choose_fetcher(date)
      date == yesterday() ? DailyECBFetcher.new : HistoricalECBFetcher.new
    end

  end
end