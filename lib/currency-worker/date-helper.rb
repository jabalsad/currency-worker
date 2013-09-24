module CurrencyWorker
  module DateHelper
    private

    def weekend?(date)
      date.saturday? || date.sunday?
    end

    def yesterday
      Time.now.utc.to_date.prev_day
    end

  end
end