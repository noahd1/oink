module Oink
  module InstanceTypeCounter
    def self.included(klass)
      ActiveRecord::Base.send(:include, OinkInstanceTypeCounterInstanceMethods)
    
      klass.class_eval do
        after_filter :report_instance_type_count
      end
    end

    def before_report_active_record_count(instantiation_data)
    end

    private
    
      def report_instance_type_count
        report_hash = ActiveRecord::Base.instantiated_hash.merge("Total" => ActiveRecord::Base.total_objects_instantiated)
        breakdown = report_hash.sort{|a,b| b[1]<=>a[1]}.collect {|k,v| "#{k}: #{v}" }.join(" | ")
        before_report_active_record_count(breakdown)
        if logger
          logger.info("Instantiation Breakdown: #{breakdown}")
        end
        ActiveRecord::Base.reset_instance_type_count
      end

  end

  module OinkInstanceTypeCounterInstanceMethods
  
    def self.included(klass)
      klass.class_eval do
      
        @@instantiated = {}
        @@total = nil
      
        def self.reset_instance_type_count
          @@instantiated = {}
          @@total = nil
        end
      
        def self.instantiated_hash
          @@instantiated
        end
        
        def self.total_objects_instantiated
          @@total ||= @@instantiated.inject(0) { |i, j| i + j.last }
        end
      
      end
    end
  
    def after_initialize
      @@instantiated[self.class.base_class.name] ||= 0
      @@instantiated[self.class.base_class.name] = @@instantiated[self.class.base_class.name] + 1  
    end
  
    def after_initialize_with_instance_type_count
      after_initialize_without_instance_type_count
      _instance_counter_after_initialize
    end
  end
end