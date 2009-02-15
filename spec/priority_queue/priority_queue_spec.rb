require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe PriorityQueue do
  
  describe "size" do
    
    it "should report the right size" do
      pq = PriorityQueue.new(5)
      pq.push(1)
      pq.size.should == 1
      pq.push(2)
      pq.size.should == 2
    end
    
    it "should be limited to the size initialized with" do
      pq = PriorityQueue.new(5)
      pq.push(1)
      pq.push(2)
      pq.push(3)
      pq.push(4)
      pq.push(5)
      pq.push(6)
      pq.size.should == 5
    end
    
  end
  
  describe "order" do
    
    it "should be in order from highest to lowest" do
      pq = PriorityQueue.new(5)
      pq.push(1)
      pq.push(2)
      pq.push(3)
      pq.to_a.should == [3,2,1]
    end
    
    it "should throw out the lower value when adding a new value" do
      pq = PriorityQueue.new(3)
      pq.push(1)
      pq.push(2)
      pq.push(3)
      pq.push(4)
      pq.to_a.should == [4,3,2]
    end
    
    it "should not make it into the queue if it's smaller than the items in the queue" do
      pq = PriorityQueue.new(3)
      pq.push(2)
      pq.push(3)
      pq.push(4)
      pq.push(1)
      pq.to_a.should == [4,3,2]
    end
    
  end
  
  describe "each" do
    it "should return each item in turn" do
      arr = []
      pq = PriorityQueue.new(5)
      pq.push(2)
      pq.push(3)
      pq.push(4)
      pq.push(1)
      pq.push(5)
      pq.each do |i|
        arr << i
      end
      arr.should == [5,4,3,2,1]
    end
  end
  
  
end