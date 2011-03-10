require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class ApplicationController

  class Logger
    attr_accessor :log

    def info(*args)
      (@log ||= []) << [:info, *args]
    end
  end

  class << self
    attr_accessor :around_filters

    def around_filter method
      (@around_filters ||= []) << method
    end
  end

  include Oink::MemoryUsageLogger

  def index
    run_around_filters
  end

  def logger
    @logger ||= Logger.new
  end

  protected
  def run_around_filters
    self.class.around_filters.each { |filter| self.send(filter) { perform_action } }
  end

  def perform_action
  end
end

describe Oink::MemoryUsageLogger do
  it "should return memory usage info from the snapshot" do
    Oink::MemorySnapshot.should_receive("memory").and_return(42)
    controller = ApplicationController.new
    controller.index
    [[:info, "Memory usage: 42 | PID: #{$$}"]].should == controller.logger.log
  end
end
