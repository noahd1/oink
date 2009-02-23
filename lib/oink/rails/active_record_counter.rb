module ActiveRecordCounter
  def self.included(klass)
    ActiveRecord::Base.send(:include, OinkActiveRecordInstanceMethods)
    
    klass.class_eval do
      after_filter :report_active_record_count
    end
  end

  private
    def report_active_record_count
      if logger
        logger.info("Instantiated #{ActiveRecord::Base.instantiated_ar_count} ActiveRecord objects")
        ActiveRecord::Base.reset_ar_count
      end
    end
end

module OinkActiveRecordInstanceMethods
  
  def self.included(klass)
    raise "Oink does not support cache_classes being false currently" if !Rails.configuration.cache_classes
    klass.class_eval do

      if klass.instance_methods.include?("after_initialize")
        alias_method_chain :after_initialize, :ar_count
      else
        define_method :after_initialize do
          _ar_counter_after_initialize
        end
      end  
            
      def self.reset_ar_count
        @@instantiated_ar_count = 0
      end

      def self.instantiated_ar_count
        @@instantiated_ar_count ||= 0
      end
    end
  end
  
  def _ar_counter_after_initialize
    @@instantiated_ar_count ||= 0
    @@instantiated_ar_count = @@instantiated_ar_count + 1
  end
  
  def after_initialize_with_ar_count
    after_initialize_without_ar_count
    _ar_counter_after_initialize
  end
  
end