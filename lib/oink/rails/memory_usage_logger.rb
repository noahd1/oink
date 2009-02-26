module Oink
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
end