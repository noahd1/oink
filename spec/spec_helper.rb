require "rspec"
require "ostruct"
require "logger"

dir = File.dirname(__FILE__)
require File.join(dir, "/../lib/oink.rb")
require "oink/rails/instance_type_counter"
require "oink/rails/memory_usage_logger"
require File.join(dir, '../config/environment')

class PsuedoOutput < Array

  def puts(line)
    self << line
  end

end

class FakeApplicationController

  def initialize(logger = Logger.new(StringIO.new))
    @logger = logger
  end

  class << self
    attr_accessor :around_filters

    def around_filter method
      (@around_filters ||= []) << method
    end
  end

  def index
    run_around_filters
  end

  def logger
    @logger
  end

  protected
  def run_around_filters
    self.class.around_filters.each { |filter| self.send(filter) { perform_action } }
  end

  def perform_action
  end
end

RSpec.configure do |config|

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