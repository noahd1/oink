require File.expand_path(File.dirname(__FILE__) + "/logged_request")

class LoggedMemoryRequest < LoggedRequest
  
  attr_accessor :memory
  
  def initialize(action, datetime, log_lines, memory)
    super(action, datetime, log_lines)
    @memory = memory
  end
  
  def <=>(other)
    self.memory <=> other.memory
  end
  
  def >(other)
    self.memory > other.memory
  end
  
end