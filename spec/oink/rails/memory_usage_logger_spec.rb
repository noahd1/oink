require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

class MemoryLoggerApplicationController < FakeApplicationController
  include Oink::MemoryUsageLogger
end

describe Oink::MemoryUsageLogger do
  it "should return memory usage info from the snapshot" do
    Oink::Instrumentation::MemorySnapshot.should_receive("memory").and_return(42)
    log_output = StringIO.new
    controller = MemoryLoggerApplicationController.new(Logger.new(log_output))
    controller.index
    log_output.string.should include("Memory usage: 42 | PID: #{$$}")
  end

  it "should log an error message if cannot find a memory snapshot strategy" do
    Oink::Instrumentation::MemorySnapshot.should_receive("memory").and_raise(Oink::Instrumentation::MemoryDataUnavailableError)
    controller = MemoryLoggerApplicationController.new
    lambda {
      controller.index
    }.should_not raise_error
  end
end
