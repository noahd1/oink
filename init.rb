require "rails/memory_usage_logger"
require "rails/active_record_counter"
ActionController::Base.send(:include, MemoryUsageLogger)
ActionController::Base.send(:include, ActiveRecordCounter)