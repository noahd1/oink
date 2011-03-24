require 'hodel_3000_compliant_logger'
require 'oink/utils/hash_utils'
require 'oink/instrumentation'

module Oink
  class Middleware

    DEFAULT_LOG_PATH = "log/oink.log"

    def initialize(app, options = {})
      @options = options
      @options[:log_path] ||= DEFAULT_LOG_PATH
      @options[:instruments] ||= [:memory, :activerecord]
      ActiveRecord::Base.send(:include, Oink::Instrumentation::ActiveRecord) if instrumented?(:activerecord)
      @logger = Hodel3000CompliantLogger.new(@options[:log_path])
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      log_routing_information(env)
      @logger.info("Completed in")
      log_memory_snapshot if instrumented?(:memory)
      log_objects_instantiated if instrumented?(:activerecord)
      reset_objects_instantiated
      [status, headers, body]
    end

    def log_routing_information(env)
      if env.has_key?('action_dispatch.request.parameters')
        controller = env['action_dispatch.request.parameters']['controller']
        action = env['action_dispatch.request.parameters']['action']
        @logger.info "Processing #{controller}##{action}"
      end
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

  private

    def instrumented?(instrument)
      @options[:instruments].include?(instrument)
    end
  end
end