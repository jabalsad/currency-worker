module CurrencyWorker
  class ECBFetcher

    require "nori"
    require "retries"
    require "rest-client"

    include CurrencyWorker::Logger

    XML_VERSION = "http://www.gesmes.org/xml/2002-08-01"
    BASE_CURRENCY = "EUR"

    def fetch(date)
      begin
        raw_data = retrieve_raw_data
        validate_data(raw_data, XML_VERSION)
        result = standardize_data(raw_data)
        closest_date = get_closest_date(result.keys, date)
        log.info "Retrieved currency data for date=#{closest_date} (requested date = #{date}): #{result[closest_date]}"
        result[closest_date.to_s]
      rescue => e
        log.error "Error retrieving currency data: #{e}"
        log.debug e.backtrace
        raise e
      end
    end

    private 

    def retrieve_raw_data
      retry_opts = {
        :max_tries => 3,
        :base_sleep_seconds => 3,
        :max_sleep_seconds => 30,
        :rescue => Errno::ETIMEDOUT,
      }
      with_retries(retry_opts) do |attempt|
        log.debug "Retrieving currency data from #{url}, attempt #{attempt}"
        xml_data = RestClient.get(url)
        data = Nori.new.parse(xml_data)
      end
    end

    def validate_data(data, xml_version)
      raise "XML data is empty" unless data
      raise "Invalid XML version" unless data["gesmes:Envelope"] &&
        data["gesmes:Envelope"]["@xmlns:gesmes"] == xml_version
      log.debug "XML data validated"
    end

    def standardize_data(data)
      cube = data["gesmes:Envelope"]["Cube"]["Cube"]
      cube = [cube] unless Array === cube
      {}.tap do |h|
        cube.each do |c|
          date = c["@time"]
          h[date] = {}
          c["Cube"].each do |entry|
            currency = entry["@currency"]
            rate = entry["@rate"]
            h[date][currency] = rate
          end
        end
      end
    end

    def get_closest_date(dates, to_date)
      d = to_date
      while d.to_s >= dates.last
        return d if dates.include? d.to_s
        log.debug "Date (#{to_date}) not found in dataset, trying previous day."
        d = d.prev_day
      end
      raise "Date not found in dataset! date=#{to_date}, set=#{dates}"
    end

  end

  class DailyECBFetcher < ECBFetcher
    private
    def url
      "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
    end
  end

  class HistoricalECBFetcher < ECBFetcher
    private
    def url
      "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"
    end
  end
end