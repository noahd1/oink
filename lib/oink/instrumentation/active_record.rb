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

          def self.reset_instance_type_count
            self.instantiated_hash = {}
            Thread.current['oink.activerecord.instantiations_count'] = nil
          end

          def self.increment_instance_type_count
            self.instantiated_hash ||= {}
            self.instantiated_hash[base_class.name] ||= 0
            self.instantiated_hash[base_class.name] += 1
          end

          def self.instantiated_hash
            Thread.current['oink.activerecord.instantiations'] ||= {}
          end

          def self.instantiated_hash=(hsh)
            Thread.current['oink.activerecord.instantiations'] = hsh
          end

          def self.total_objects_instantiated
            Thread.current['oink.activerecord.instantiations_count'] ||= self.instantiated_hash.values.sum
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