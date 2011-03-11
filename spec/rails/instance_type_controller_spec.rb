require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class ARCountApplicationController < FakeApplicationController
  include Oink::InstanceTypeCounter

  def no_pigs
    run_around_filters
  end

  def two_pigs_in_a_pen
    Pig.create!
    Pig.create!
    Pen.create!
    run_around_filters
  end

  def two_pigs
    Pig.create!
    Pig.create!
    run_around_filters
  end

end

describe Oink::MemoryUsageLogger do

  let(:log_output)  { StringIO.new }
  let(:logger)      { Logger.new(log_output) }

  it "reports no AR objects instantiated" do
    controller = ARCountApplicationController.new(logger)
    controller.no_pigs
    log_output.string.should include("Instantiation Breakdown: Total: 0")
  end

  it "reports AR objects instantiated by type" do
    controller = ARCountApplicationController.new(logger)
    controller.two_pigs_in_a_pen
    log_output.string.should include("Instantiation Breakdown: Total: 3 | Pig: 2 | Pen: 1")
  end

  it "reports totals first even if its a tie" do
    controller = ARCountApplicationController.new(logger)
    controller.two_pigs
    log_output.string.should include("Instantiation Breakdown: Total: 2 | Pig: 2")
  end
end