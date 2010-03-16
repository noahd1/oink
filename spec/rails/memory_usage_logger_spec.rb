require "rubygems"
require "mocha"
require "active_support"

dir = File.dirname(__FILE__)
require File.join(dir, "/../../lib/oink.rb")
require "oink/rails/memory_usage_logger"
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
    attr_accessor :after_filters

    def after_filter method
      (@after_filters ||= []) << method
    end
  end

  include Oink::MemoryUsageLogger

  def index
    run_after_filters
  end

  def logger
    @logger ||= Logger.new
  end

  def `(*args)
    (@backtick ||= []) << args
    '915'
  end

  protected
  def run_after_filters
    self.class.after_filters.each { |filter| self.send(filter) }
  end
end

describe Oink::MemoryUsageLogger do
  unless defined? WIN32OLE
    describe "get_memory_usage" do
      it "should work on linux" do
        proc_file = <<-STR
            Header

            Size: 25
            Size: 13 trailing

      leading Size: 4

            Footer

            STR

        File.stubs(:new).returns(proc_file).with { |filename| filename == "/proc/#{$$}/smaps" or raise ScriptError, "Bad filename '#{filename}'" }
        controller = ApplicationController.new
        controller.index
        [[:info, "Memory usage: 42 | PID: #{$$}"]].should == controller.logger.log
      end

      it "should work on non-linux" do
        File.stubs(:new).raises(Errno::ENOENT, "No such file or directory")
        controller = ApplicationController.new
        controller.index
        [["ps -o vsz= -p #{$$}"]].should == controller.backtick
        [[:info, "Memory usage: 915 | PID: #{$$}"]].should == controller.logger.log
      end
    end
  end
end
