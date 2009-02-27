#!/usr/bin/env ruby

require 'benchmark'

require File.dirname(__FILE__) + "/../lib/oink.rb"

Benchmark.bmbm(15) do |x|
  x.report("Running Oink") { 
    f = File.open(File.expand_path(File.dirname(__FILE__) + "/../logs/production.log"))
    Oink::MemoryUsageReporter.new([f], 75*1024).print(STDOUT)
    f.close
  }
end

