class PriorityQueue
  
  include Enumerable
  
  def initialize(size)
    @size = size
    @queue = []
  end
  
  def push(item)
    if @queue.size < @size
      @queue << item
    elsif item > @queue.last
      @queue[@size - 1] = item
    end
    prioritize
  end
  
  def to_a
    @queue
  end
  
  def size
    @queue.size
  end
  
  def each
    @queue.each { |i| yield i }
  end
  
protected

  def prioritize
    @queue.sort! { |a, b| b <=> a }
  end
  
end