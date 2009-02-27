require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Oink::OinkInstanceTypeCounterInstanceMethods do
  before :each do
    ActiveRecord::Base.reset_instance_type_count
  end
  
  describe "hash" do
    it "should not count objects not instantiated" do
      ActiveRecord::Base.instantiated_hash["Pig"].should == nil
    end
    
    it "should include the objects instantiated" do
      Pig.create(:name => "Babe")
      Pig.first
      ActiveRecord::Base.instantiated_hash["Pig"].should == 2
    end
    
    it "should count instantiations for multiple classes" do
      Pig.create(:name => "Babe")
      Pen.create(:location => "Backyard")
      Pig.first
      ActiveRecord::Base.instantiated_hash["Pen"].should == 1
    end
    
    it "should report the total number of objects instantiated" do
      Pig.create(:name => "Babe")
      Pen.create(:location => "Backyard")
      Pig.first
      ActiveRecord::Base.total_objects_instantiated.should == 3
    end    
  end
  
  describe "reset" do
    it "should reset the total count" do
      Pig.create(:name => "Babe")
      ActiveRecord::Base.instantiated_hash["Pig"].should == 1
      ActiveRecord::Base.reset_instance_type_count
      ActiveRecord::Base.total_objects_instantiated.should == 0
      Pig.create(:name => "Babe")
      ActiveRecord::Base.total_objects_instantiated.should == 0
    end
  end
  
end