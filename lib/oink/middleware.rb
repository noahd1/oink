require 'hodel_3000_compliant_logger'
require 'oink/utils/hash_utils'
require 'oink/instrumentation'

module Oink
  class Middleware

    def initialize(app, options = {})
      @app         = app
      @path        = options[:path] || false
      @logger      = options[:logger] || Hodel3000CompliantLogger.new("log/oink.log")
      @instruments = options[:instruments] ? Array(options[:instruments]) : [:memory, :activerecord]

      Oink.extend_active_record! if @instruments.include?(:activerecord)
    end

    def call(env)
      status, headers, body = @app.call(env)

      log_routing(env)
      log_memory
      log_activerecord
      log_completed
      [status, headers, body]
    end

    def log_completed
      @logger.info("Oink Log Entry Complete")
    end

    def log_routing(env)
      info = rails3_routing_info(env) || rails2_routing_info(env)
      if info
        if @path && info[:path_info]
          @logger.info("Oink Path: #{info[:path_info]}")
        elsif info[:request]
          @logger.info("Oink Action: #{info[:request]['controller']}##{info[:request]['action']}")
        end
      end
    end

    def log_memory
      if @instruments.include?(:memory)
        memory = Oink::Instrumentation::MemorySnapshot.memory
        @logger.info("Memory usage: #{memory} | PID: #{$$}")
      end
    end

    def log_activerecord
      if @instruments.include?(:activerecord)
        sorted_list = Oink::HashUtils.to_sorted_array(ActiveRecord::Base.instantiated_hash)
        sorted_list.unshift("Total: #{ActiveRecord::Base.total_objects_instantiated}")
        @logger.info("Instantiation Breakdown: #{sorted_list.join(' | ')}")
        reset_objects_instantiated
      end
    end

  private

    def rails3_routing_info(env)
      if env['action_dispatch.request.parameters']
        {
          :request => env['action_dispatch.request.parameters'],
          :path_info => env['PATH_INFO'],
        }
      else
        nil
      end
    end

    def rails2_routing_info(env)
      if env['action_controller.request.path_parameters']
        {
          :request => env['action_controller.request.path_parameters'],
          :path_info => env['PATH_INFO'],
        }
      else
        nil
      end
    end

    def reset_objects_instantiated
      ActiveRecord::Base.reset_instance_type_count
    end

  end
end
