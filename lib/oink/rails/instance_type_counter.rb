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

        def self.increment_instance_type_count
          @@instantiated[base_class.name] ||= 0
          @@instantiated[base_class.name] += 1
        end

        def self.instantiated_hash
          @@instantiated
        end

        def self.total_objects_instantiated
          @@total ||= @@instantiated.values.sum
        end

        unless Oink.extended_active_record?
          class << self
            alias_method :allocate_before_oink, :allocate

            def allocate
              value = allocate_before_oink
              increment_instance_type_count
              value
            end
          end

          alias_method :initialize_before_oink, :initialize

          def initialize(*args, &block)
            value = initialize_before_oink(*args, &block)
            self.class.increment_instance_type_count
            value
          end

          Oink.extended_active_record!
        end
      end
    end
  end
end
