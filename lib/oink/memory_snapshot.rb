module Oink

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
      @statm_page_size ||= (`getconf PAGESIZE`.strip.to_i rescue 4096) / 1024
    end

    def self.available?
      File.exist?("/proc/self/statm")
    end
  end

  class SmapsMemorySnapshot
    def memory
      proc_file = File.new("/proc/#{$$}/smaps")
      proc_file.map do |line|
        size = line[/Size: *(\d+)/, 1] and size.to_i
      end.compact.sum
    end

    def self.available?
      File.exist?("/proc/#{$$}/smaps")
    end
  end

  class ProcessStatusMemorySnapshot
    def memory
      self.class.memory
    end

    def self.memory
      `ps -o vsz= -p #{$$}`.to_i
    end

    def self.available?
      `ps -o vsz= -p #{$$}` rescue false
    end
  end
end