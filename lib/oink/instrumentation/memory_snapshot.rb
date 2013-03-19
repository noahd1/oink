module Oink

  module Instrumentation

    class MemorySnapshot
      def self.memory
        memory_snapshot_class.new.memory
      end

      def self.memory_snapshot_class
        @@memory_snapshot_class ||= begin
          [WindowsMemorySnapshot,
           StatmMemorySnapshot,
           SmapsMemorySnapshot,
           ProcessStatusMemorySnapshot].find { |snapshot_class| snapshot_class.available? }
        end

        raise MemoryDataUnavailableError if @@memory_snapshot_class.nil?
        @@memory_snapshot_class
      end
    end

    class WindowsMemorySnapshot

      begin
        require 'win32ole'
      rescue LoadError
      end

      def memory
        wmi = WIN32OLE.connect("winmgmts:root/cimv2")
        mem = 0
        query = "select * from Win32_Process where ProcessID = #{$$}"
        wmi.ExecQuery(query).each do |wproc|
          mem = wproc.WorkingSetSize
        end
        mem.to_i / 1000
      end

      def self.available?
        defined? WIN32OLE
      end
    end

    class StatmMemorySnapshot
      def memory
        pages = File.read("/proc/self/statm")
        pages.to_i * self.class.statm_page_size
      end

      # try to get and cache memory page size. falls back to 4096.
      def self.statm_page_size
        @statm_page_size ||= begin
          sys_call = SystemCall.execute("getconf PAGESIZE")
          if sys_call.success?
            sys_call.stdout.strip.to_i / 1024
          else
            4
          end
        end
      end

      def self.unset_statm_page_size
        @statm_page_size = nil
      end

      def self.available?
        File.exist?("/proc/self/statm")
      end
    end

    class SmapsMemorySnapshot
      def memory
        proc_file = File.new("/proc/#{$$}/smaps")
        lines = proc_file.lines
        lines.map do |line|
          size = line[/Size: *(\d+)/, 1] and size.to_i
        end.compact.sum
      end

      def self.available?
        File.exist?("/proc/#{$$}/smaps")
      end
    end

    class ProcessStatusMemorySnapshot
      def memory
        SystemCall.execute("ps -o vsz= -p #{$$}").stdout.to_i
      end

      def self.available?
        SystemCall.execute("ps -o vsz= -p #{$$}").success?
      end
    end

    class SystemCall

      def initialize(cmd)
        @stdout = `#{cmd}`
        @process_status = $?
      end

      def self.execute(cmd)
        new(cmd)
      end

      def stdout
        @stdout
      end

      def success?
        @process_status.success?
      end

    end

    class MemoryDataUnavailableError < StandardError; end

  end

end
