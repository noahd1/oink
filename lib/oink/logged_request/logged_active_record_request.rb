require File.expand_path(File.dirname(__FILE__) + "/logged_request")

class LoggedActiveRecordRequest < LoggedRequest
  
  attr_accessor :ar_count
  
  def initialize(action, datetime, log_lines, ar_count)
    super(action, datetime, log_lines)
    @ar_count = ar_count
  end
  
  def <=>(other)
    self.ar_count <=> other.ar_count
  end
  
  def >(other)
    self.ar_count > other.ar_count
  end
  
end