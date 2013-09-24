module CurrencyWorker
  class Invoker

    require "optparse"
    require "time"
    include CurrencyWorker::Logger
    include CurrencyWorker::DateHelper

    def initialize(args)
      @date = yesterday()

      OptionParser.new do |o|
        o.on("-d","--date=ISO8601","The date to pull data for, in ISO8601 format",
             "Default: #{@date}") do |v|
          @date = Date.parse(v)
          raise "Cannot specify date later than #{yesterday()}: #{@date}" if @date > yesterday()
        end
      end.parse!

      Logger.setup
    end

    def run
      Orchestrator.new.start(@date)
    end

  end
end