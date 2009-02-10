class LoggedRequest
  
  attr_accessor :action, :datetime, :memory
  
  def initialize(action, datetime, memory)
    @action = action
    @datetime = datetime
    @memory = memory
  end
  
  def <=>(other)
    self.memory <=> other.memory
  end
  
  def >(other)
    self.memory > other.memory
  end
  
end