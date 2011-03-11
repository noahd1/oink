require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class UseInstanceTypeCounterApplicationController < FakeApplicationController
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
  it "reports no AR objects instantiated" do
    controller = UseInstanceTypeCounterApplicationController.new
    controller.no_pigs
    [[:info, "Instantiation Breakdown: Total: 0"]].should == controller.logger.log
  end

  it "reports AR objects instantiated by type" do
    controller = UseInstanceTypeCounterApplicationController.new
    controller.two_pigs_in_a_pen
    [[:info, "Instantiation Breakdown: Total: 3 | Pig: 2 | Pen: 1"]].should == controller.logger.log
  end

  it "reports totals first even if its a tie" do
    controller = UseInstanceTypeCounterApplicationController.new
    controller.two_pigs
    [[:info, "Instantiation Breakdown: Total: 2 | Pig: 2"]].should == controller.logger.log
  end
end