require 'hodel_3000_compliant_logger'
require 'oink/utils/hash_utils'
require 'oink/instrumentation'

module Oink
  class Middleware

    def initialize(app, logger = Hodel3000CompliantLogger.new("oink.log"))
      ActiveRecord::Base.send(:include, Oink::Instrumentation::ActiveRecord)
      @app = app
      @logger = logger
    end

    def call(env)
      status, headers, body = @app.call(env)
      @logger.info("Completed in")
      log_memory_snapshot
      log_objects_instantiated
      reset_objects_instantiated
      [status, headers, body]
    end

    def log_memory_snapshot
      memory = Oink::Instrumentation::MemorySnapshot.memory
      @logger.info("Memory usage: #{memory} | PID: #{$$}")
    end

    def log_objects_instantiated
      sorted_list = Oink::HashUtils.to_sorted_array(ActiveRecord::Base.instantiated_hash)
      sorted_list.unshift("Total: #{ActiveRecord::Base.total_objects_instantiated}")
      @logger.info("Instantiation Breakdown: #{sorted_list.join(' | ')}")
    end

    def reset_objects_instantiated
      ActiveRecord::Base.reset_instance_type_count
    end

  end
end