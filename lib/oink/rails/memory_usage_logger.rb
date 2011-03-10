require 'oink/memory_snapshot'

module Oink
  module MemoryUsageLogger
    def self.included(klass)
      klass.class_eval do
        around_filter :log_memory_usage
      end
    end

  private

    def log_memory_usage
      yield
      if logger
        memory_usage = MemorySnapshot.memory
        logger.info("Memory usage: #{memory_usage} | PID: #{$$}")
      end
    end
  end
end