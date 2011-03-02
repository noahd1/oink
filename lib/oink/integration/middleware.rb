module Oink
  module Integration
    class Middleware

      def self.io=(io)
        @@io = io
      end

      def self.io
        @@io
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)
        report_hash = ActiveRecord::Base.instantiated_hash.merge("Total" => ActiveRecord::Base.total_objects_instantiated)
        breakdown = report_hash.sort{|a,b| b[1]<=>a[1]}.collect {|k,v| "#{k}: #{v}" }.join(" | ")
        @@io = "Instantiation Breakdown: #{breakdown}" if @@io
        ActiveRecord::Base.reset_instance_type_count
        [status, headers, body]
      end
    end
  end
end