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
          wmi = WIN32OLE.connect("winmgmts:root/cimv2")
          mem = 0
          query = "select * from Win32_Process where ProcessID = #{$$}"
          wmi.ExecQuery(query).each do |wproc|
            mem = wproc.WorkingSetSize
          end
          mem.to_i / 1000
        elsif pages = File.read("/proc/self/statm") rescue nil
          pages.to_i * statm_page_size
        elsif proc_file = File.new("/proc/#{$$}/smaps") rescue nil
          proc_file.map do |line|
            size = line[/Size: *(\d+)/, 1] and size.to_i
          end.compact.sum
        else
          `ps -o vsz= -p #{$$}`.to_i
        end
      end

      # try to get and cache memory page size. falls back to 4096.
      def statm_page_size
        @statm_page_size ||= (`getconf PAGESIZE`.strip.to_i rescue 4096) / 1024
      end

      def log_memory_usage
        if logger
          memory_usage = get_memory_usage
          logger.info("Memory usage: #{memory_usage} | PID: #{$$}")
        end
      end
  end
end