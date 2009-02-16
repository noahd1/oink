class Oink
  
  VERSION = '0.1.0'
  FORMATS = %w[verbose short-summary summary]
  FORMAT_ALIASES = { "v" => "verbose", "ss" => "short-summary", "s" => "summary" }
  
  def initialize(input, threshold, options = {})
    @inputs = Array(input)
    @threshold = threshold
    @format = options[:format] || :short_summary
    
    @pids = {}
    @bad_actions = {}
    @bad_requests = PriorityQueue.new(10)
  end
  
  
end