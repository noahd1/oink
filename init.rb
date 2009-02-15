require "memory_usage_logger"
require "active_record_counter"
ActionController::Base.send(:include, MemoryUsageLogger)
ActionController::Base.send(:include, ActiveRecordCounter)