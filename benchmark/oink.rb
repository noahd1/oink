#!/usr/bin/env ruby

require 'benchmark'

$:.unshift(File.dirname(__FILE__ + '.rb') + '/../lib') unless $:.include?(File.dirname(__FILE__ + '.rb') + '/../lib')
require "oink"

Benchmark.bmbm(15) do |x|
  x.report("Running Oink") { 
    f = File.open(File.expand_path(File.dirname(__FILE__) + "/../logs/production.log"))
    OinkForMemory.new([f], 75*1024).each_line do |line|
    end
    f.close
  }
end

