#!/usr/bin/env ruby

require 'benchmark'
require 'active_record'
require 'sqlite3'
require File.dirname(__FILE__) + "/../lib/oink.rb"
require File.dirname(__FILE__) + "/../init"

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database  => ':memory:'
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.timestamps
  end
end

class User < ActiveRecord::Base
end

Benchmark.bm(15) do |x|
  x.report "40,000 empty iterations" do
    40_000.times {}
  end

  x.report "without instance type counter - instantiating 40,000 objects" do
    40_000.times do
      User.new
    end
  end

  x.report "with instance type counter - instating 40,000 objects" do
    ActiveRecord::Base.send(:include, Oink::OinkInstanceTypeCounterInstanceMethods)

    40_000.times do
      User.new
    end
  end
end