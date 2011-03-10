require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Oink::MemorySnapshot do
  unless defined? WIN32OLE
    describe "get_memory_usage" do
      it "should work on linux with statm" do
        pages = 6271
        statm_file = "#{pages} 1157 411 1 0 763 0\n"
        File.should_receive(:read).with("/proc/self/statm").and_return(statm_file)
        Oink::StatmMemorySnapshot.should_receive(:`).with('getconf PAGESIZE').and_return("4096\n")
        Oink::StatmMemorySnapshot.new.memory.should == (pages * 4)
      end

      it "should work on linux with smaps" do
        proc_file = <<-STR
            Header

            Size: 25
            Size: 13 trailing

      leading Size: 4

            Footer

            STR
        File.should_receive(:new).with("/proc/#{$$}/smaps").and_return(proc_file)
        Oink::SmapsMemorySnapshot.new.memory.should == 42
      end

      it "should work on non-linux" do
        Oink::ProcessStatusMemorySnapshot.should_receive(:`).and_return('915')
        Oink::ProcessStatusMemorySnapshot.memory.should == 915
      end
    end
  end
end