module ActiveRecordCounter
  def self.included(klass)
    ActiveRecord::Base.send(:extend, OinkActiveRecordClassMethods)
    ActiveRecord::Base.send(:extend, OinkActiceRecordInstanceMethods)
    
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
  
  def reset_ar_count
    @@instantiated_ar_count = 0
  end

  def instantiated_ar_count
    @@instantiated_ar_count ||= 0
  end

end

module OinkActiceRecordInstanceMethods
  
  def after_initialize
    @@instantiated_ar_count ||= 0
    @@instantiated_ar_count = @@instantiated_ar_count + 1
  end
  
end