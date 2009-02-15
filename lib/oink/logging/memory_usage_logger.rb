module MemoryUsageLogger
  def self.included(klass)
    klass.class_eval do
      after_filter :log_memory_usage
    end
  end
  
  private
    def log_memory_usage
      if logger
        memory_usage = `ps -o rss= -p #{$$}`.to_i
        logger.info("Memory usage: #{memory_usage} | PID: #{$$}")
      end
    end
end

ActiveSupport::BufferedLogger.class_eval do
  def add_with_memory_info(severity, message = nil, progname = nil, &block)
    memory_usage = `ps -o rss= -p #{$$}`.to_i
    message = (message || (block && block.call) || progname).to_s
    message += " (mem #{memory_usage})"
    add_without_memory_info(severity, message, progname, &block)
  end
  
  alias_method_chain :add, :memory_info
end