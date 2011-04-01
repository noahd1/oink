require 'hodel_3000_compliant_logger'
require 'oink/utils/hash_utils'
require 'oink/instrumentation'

module Oink
  class Middleware

    DEFAULT_LOG_PATH = "log/oink.log"

    def initialize(app, options = {})
      @app         = app
      @log_path    = options[:log_path]    || DEFAULT_LOG_PATH
      @instruments = options[:instruments] || [:memory, :activerecord]

      ActiveRecord::Base.send(:include, Oink::Instrumentation::ActiveRecord) if @instruments.include?(:activerecord)
    end

    def call(env)
      status, headers, body = @app.call(env)

      log_routing(env)
      log_completed
      log_memory
      log_activerecord

      reset_objects_instantiated
      [status, headers, body]
    end

    def log_completed
      logger.info("Completed in")
    end

    def log_routing(env)
      if env.has_key?('action_dispatch.request.parameters')
        controller = env['action_dispatch.request.parameters']['controller']
        action     = env['action_dispatch.request.parameters']['action']
        logger.info("Processing #{controller}##{action}")
      end
    end

    def log_memory
      if @instruments.include?(:memory)
        memory = Oink::Instrumentation::MemorySnapshot.memory
        logger.info("Memory usage: #{memory} | PID: #{$$}")
      end
    end

    def log_activerecord
      if @instruments.include?(:activerecord)
        sorted_list = Oink::HashUtils.to_sorted_array(ActiveRecord::Base.instantiated_hash)
        sorted_list.unshift("Total: #{ActiveRecord::Base.total_objects_instantiated}")
        logger.info("Instantiation Breakdown: #{sorted_list.join(' | ')}")
      end
    end

  private

    def reset_objects_instantiated
      ActiveRecord::Base.reset_instance_type_count
    end

    def logger
      @logger ||= Hodel3000CompliantLogger.new(@log_path)
    end
  end
end
