module Oink
  module Integration
    class Middleware

      def self.logger=(logger)
        @logger = logger
      end

      def self.logger
        @logger
      end

      def logger
        self.class.logger
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)
        report_hash = ActiveRecord::Base.instantiated_hash.merge("Total" => ActiveRecord::Base.total_objects_instantiated)
        breakdown = report_hash.sort{|a,b| b[1]<=>a[1]}.collect {|k,v| "#{k}: #{v}" }.join(" | ")
        logger.info("Instantiation Breakdown: #{breakdown}") if logger
        ActiveRecord::Base.reset_instance_type_count
        [status, headers, body]
      end
    end
  end
end