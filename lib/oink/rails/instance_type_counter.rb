require 'oink/instrumentation/active_record'

module Oink

  module InstanceTypeCounter
    def self.included(klass)
      ActiveRecord::Base.send(:include, Oink::Instrumentation::ActiveRecord)

      klass.class_eval do
        around_filter :report_instance_type_count
      end
    end

    def before_report_active_record_count(instantiation_data)
    end

    private

      def report_instance_type_count
        sorted_list = Oink::HashUtils.to_sorted_array(ActiveRecord::Base.instantiated_hash)
        sorted_list.unshift("Total: #{ActiveRecord::Base.total_objects_instantiated}")
        breakdown = sorted_list.join(" | ")
        before_report_active_record_count(breakdown)
        if logger
          logger.info("Instantiation Breakdown: #{breakdown}")
        end
        ActiveRecord::Base.reset_instance_type_count
      end
  end

end
