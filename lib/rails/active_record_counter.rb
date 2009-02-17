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

module OinkActiveRecordClassMethods


end

module OinkActiveRecordInstanceMethods
  
  def self.included(klass)
    klass.class_eval do
      def self.reset_ar_count
        @@instantiated_ar_count = 0
      end

      def self.instantiated_ar_count
        @@instantiated_ar_count ||= 0
      end
    end
  end
  
  def after_initialize
    @@instantiated_ar_count ||= 0
    @@instantiated_ar_count = @@instantiated_ar_count + 1
  end
  
end