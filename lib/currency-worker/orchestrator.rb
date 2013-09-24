module CurrencyWorker
  class Orchestrator

    require "aws"
    require "retries"
    
    include CurrencyWorker::Logger

    def initialize
      @config = Config.instance
      AWS.config(:credential_provider => AWS::Core::CredentialProviders::EC2Provider.new) 
      @dynamo = AWS::DynamoDB.new(
        :logger => log,
        :region => @config.aws_region)
    end

    def start(date)
      begin 
        log.info "Processing date=#{date}..."
        table = DynamoCreator.new(@dynamo).get_table(@config.dynamo)
        writer = DynamoWriter.new(table)
        unless writer.date_exists? date
          rates = Fetcher.new.fetch(date) 
          writer.write(date, rates)
        end
        log.info "Completed processing for date=#{date}"
      rescue => e
        log.error "Error during processing date=#{date}: #{e}"
        log.debug e.backtrace
        exit 1
      end
    end

  end
end