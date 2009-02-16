require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe OinkedRequest do
  
  describe "sort" do
    it "should sort by memory used" do
      lr1 = OinkedRequest.new("Controller#Action", "February 1 10:20", [], 10)
      lr2 = OinkedRequest.new("Controller#Action", "February 1 10:20", [], 5)
      lr3 = OinkedRequest.new("Controller#Action", "February 1 10:20", [], 30)
      
      [lr1, lr2, lr3].sort.should == [lr2, lr1, lr3]
    end
  end
  
  
end