class LoggedRequest
  
  attr_accessor :action, :datetime, :memory, :log_lines
  
  def initialize(action, datetime, memory, log_lines)
    @action = action
    @datetime = datetime
    @memory = memory
    @log_lines = log_lines
  end
  
  def <=>(other)
    self.memory <=> other.memory
  end
  
  def >(other)
    self.memory > other.memory
  end
  
end