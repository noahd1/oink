module Oink

  def self.extended_active_record?
    @oink_extended_active_record
  end

  def self.extended_active_record!
    @oink_extended_active_record = true
  end

  def self.extend_active_record!
    ::ActiveRecord::Base.class_eval do
      include Instrumentation::ActiveRecord
    end
  end

  module Instrumentation
    module ActiveRecord

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
end