#!/usr/bin/env ruby

if $0 == __FILE__
  require "currency-worker"
  CurrencyWorker::Invoker.new(ARGV).run
end