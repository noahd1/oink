begin
  require 'win32ole'
rescue LoadError
end

module Oink
  module MemoryUsageLogger
    def self.included(klass)
      klass.class_eval do
        after_filter :log_memory_usage
      end
    end
  
    private
      def get_memory_usage
        if defined? WIN32OLE
          wmi = WIN32OLE.connect("winmgmts://./root/cimv2")
          mem = 0
          wmi.InstancesOf("Win32_Process").each do |wproc|
            next unless wproc.ProcessId == $$
            mem = wproc.WorkingSetSize.to_i
            break
          end
          mem
        else
          `ps -o rss= -p #{$$}`.to_i
        end
      end

      def log_memory_usage
        if logger
          memory_usage = get_memory_usage
          logger.info("Memory usage: #{memory_usage} | PID: #{$$}")
        end
      end
  end
end