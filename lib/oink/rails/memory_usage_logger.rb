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
        begin
          memory_usage = MemorySnapshot.memory
          logger.info("Memory usage: #{memory_usage} | PID: #{$$}")
        rescue Oink::MemoryDataUnavailableError => e
          logger.error("Oink unable to retrieve memory on this system. See Oink::MemorySnapshot in source.")
        end
      end
    end
  end
end