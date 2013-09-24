module CurrencyWorker
  module Logger
    require "log4r"

    def log
      @log ||= Log4r::Logger.new(self.class.name)
    end

    def self.setup
      log = Log4r::Logger.new(self.name.split("::").first)
      Log4r::Outputter.stdout.formatter = Log4r::PatternFormatter.new({:pattern => '%d %l %c - %m'})
      log.outputters << Log4r::Outputter.stdout
    end
  end
end