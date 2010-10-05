require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class ApplicationController
  attr_accessor :backtick

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

  def `(*args)
    (@backtick ||= []) << args
    '915'
  end

  protected
  def run_around_filters
    self.class.around_filters.each { |filter| self.send(filter) { perform_action } }
  end

  def perform_action
  end
end

describe Oink::MemoryUsageLogger do
  unless defined? WIN32OLE
    describe "get_memory_usage" do
      it "should work on linux with statm" do
        pages = 6271
        statm_file = "#{pages} 1157 411 1 0 763 0\n"

        File.should_receive(:read).with("/proc/self/statm").and_return(statm_file)
        controller = ApplicationController.new
        controller.should_receive(:`).with('getconf PAGESIZE').and_return("4096\n")
        controller.index
        controller.logger.log.should == [[:info, "Memory usage: #{pages * 4} | PID: #{$$}"]]
      end

      it "should work on linux with smaps" do
        proc_file = <<-STR
            Header

            Size: 25
            Size: 13 trailing

      leading Size: 4

            Footer

            STR

        File.stub!(:read).and_raise(Errno::ENOENT.new("No such file or directory"))
        File.should_receive(:new).with("/proc/#{$$}/smaps").and_return(proc_file)
        controller = ApplicationController.new
        controller.index
        [[:info, "Memory usage: 42 | PID: #{$$}"]].should == controller.logger.log
      end

      it "should work on non-linux" do
        File.stub!(:read).and_raise(Errno::ENOENT.new("No such file or directory"))
        File.stub!(:new).and_raise(Errno::ENOENT.new("No such file or directory"))
        controller = ApplicationController.new
        controller.index
        [["ps -o vsz= -p #{$$}"]].should == controller.backtick
        [[:info, "Memory usage: 915 | PID: #{$$}"]].should == controller.logger.log
      end
    end
  end
end
