class OinkedRequest
  
  attr_accessor :action, :datetime, :log_lines, :oink_number
  
  def initialize(action, datetime, log_lines, oink_number)
    @action = action
    @datetime = datetime
    @log_lines = log_lines
    @oink_number = oink_number
  end
  
  def <=>(other)
    self.oink_number <=> other.oink_number
  end
  
  def >(other)
    self.oink_number > other.oink_number
  end  
  
end