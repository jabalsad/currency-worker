module CurrencyWorker
  class Converter

    def self.convert(data, current_base, new_base, current_base_precision=4)
      d = data.dup
      factor = d.delete(new_base).to_f

      d[current_base] = "%0.#{current_base_precision}f" % 1.0

      {}.tap do |converted|
        d.each do |currency, rate|
          precision = rate.split(".").last.size
          new_rate = (rate.to_f / factor).round(precision)
          converted[currency] = "%0.#{precision}f" % new_rate
        end
      end
    end

  end
end