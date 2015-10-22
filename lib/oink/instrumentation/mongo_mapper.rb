module Oink
  def self.extended_mongo_mapper?
    @oink_extended_mongo_mapper
  end

  def self.extended_mongo_mapper!
    @oink_extended_mongo_mapper = true
  end

  def self.extend_mongo_mapper!
    return if extended_mongo_mapper?

    ::MongoMapper::Document.instance_eval do
      def included(klass)
        super

        klass.class_eval do
          class << self
            alias_method :allocate_before_oink, :allocate

            def allocate
              value = allocate_before_oink
              Oink::Instrumentation::MongoMapper.increment_instance_type_count(self)
              value
            end
          end

          alias_method :initialize_before_oink, :initialize

          def initialize(*args, &block)
            value = initialize_before_oink(*args, &block)
            Oink::Instrumentation::MongoMapper.increment_instance_type_count(self.class)
            value
          end

          Oink.extended_mongo_mapper!
        end
      end
    end
  end

  module Instrumentation
    module MongoMapper
      def self.reset_instance_type_count
        self.instantiated_hash = {}
        Thread.current['oink.mongomapper.instantiations_count'] = nil
      end

      def self.increment_instance_type_count(klass)
        self.instantiated_hash ||= {}
        self.instantiated_hash[klass.name] ||= 0
        self.instantiated_hash[klass.name] += 1
      end

      def self.instantiated_hash
        Thread.current['oink.mongomapper.instantiations'] ||= {}
      end

      def self.instantiated_hash=(hsh)
        Thread.current['oink.mongomapper.instantiations'] = hsh
      end

      def self.total_objects_instantiated
        Thread.current['oink.mongomapper.instantiations_count'] ||= self.instantiated_hash.values.sum
      end
    end
  end
end