module Oink
  module Integration
    class Middleware

      def initialize(app, logger = Hodel3000CompliantLogger.new("oink.log"))
        @app = app
        @logger = logger
      end

      def call(env)
        status, headers, body = @app.call(env)
        log_objects_instantiated
        reset_objects_instantiated
        [status, headers, body]
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
end