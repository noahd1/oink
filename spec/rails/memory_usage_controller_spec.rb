require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class UseMemoryLoggerApplicationController < FakeApplicationController
  include Oink::MemoryUsageLogger
end

describe Oink::MemoryUsageLogger do
  it "should return memory usage info from the snapshot" do
    Oink::MemorySnapshot.should_receive("memory").and_return(42)
    log_output = StringIO.new
    controller = UseMemoryLoggerApplicationController.new(Logger.new(log_output))
    controller.index
    log_output.string.should include("Memory usage: 42 | PID: #{$$}")
  end

  it "should log an error message if cannot find a memory snapshot strategy" do
    Oink::MemorySnapshot.should_receive("memory").and_raise(Oink::MemoryDataUnavailableError)
    controller = UseMemoryLoggerApplicationController.new
    lambda {
      controller.index
    }.should_not raise_error
  end
end
