module Oink
  module Integration
    class Middleware

      def initialize(app, logger = Hodel3000CompliantLogger.new("oink.log"))
        @app = app
        @logger = logger
      end

      def call(env)
        status, headers, body = @app.call(env)
        report_hash = ActiveRecord::Base.instantiated_hash.merge("Total" => ActiveRecord::Base.total_objects_instantiated)
        breakdown = report_hash.sort{|a,b| b[1]<=>a[1]}.collect {|k,v| "#{k}: #{v}" }.join(" | ")
        @logger.info("Instantiation Breakdown: #{breakdown}")
        ActiveRecord::Base.reset_instance_type_count
        [status, headers, body]
      end
    end
  end
end