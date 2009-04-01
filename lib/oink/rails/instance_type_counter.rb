module Oink
  
  def self.extended_active_record?
    @oink_extended_active_record
  end

  def self.extended_active_record!
    @oink_extended_active_record = true
  end
  
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

        unless Oink.extended_active_record?
          if instance_methods.include?("after_initialize")
            def after_initialize_with_oink
              after_initialize_without_oink
              increment_ar_count
            end
          
            alias_method_chain :after_initialize, :oink
          else
            def after_initialize
              increment_ar_count
            end
          end
          
          Oink.extended_active_record!
        end
      
      end
    end
  
    def increment_ar_count
      @@instantiated[self.class.base_class.name] ||= 0
      @@instantiated[self.class.base_class.name] = @@instantiated[self.class.base_class.name] + 1  
    end

  end
end