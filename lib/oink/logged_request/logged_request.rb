class LoggedRequest
  
  attr_accessor :action, :datetime, :memory, :log_lines
  
  def initialize(action, datetime, log_lines)
    @action = action
    @datetime = datetime
    @log_lines = log_lines
  end
  
end