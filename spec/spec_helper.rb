require "rubygems"
require "spec"
require 'ostruct'

dir = File.dirname(__FILE__)
require File.join(dir, "/../lib/oink.rb")
require "oink/rails/instance_type_counter"
require File.join(dir, '../config/environment')

class PsuedoOutput < Array
  
  def puts(line)
    self << line
  end
  
end

Spec::Runner.configure do |config|

  config.before :suite do
    load File.join(dir, "../db/schema.rb")
  end

  config.before :each do
    Pig.delete_all
    Pen.delete_all
  end

  config.before :suite do
    ActiveRecord::Base.send(:include, Oink::OinkInstanceTypeCounterInstanceMethods)
    Pig = Class.new(ActiveRecord::Base)
    Pen = Class.new(ActiveRecord::Base)
    Pig.belongs_to :pen
  end

end