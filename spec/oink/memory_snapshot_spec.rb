require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Oink::StatmMemorySnapshot do

  before do
    Oink::StatmMemorySnapshot.unset_statm_page_size
  end

  it "returns memory when pagesize is 4096" do
    pages = 6271
    statm_file = "#{pages} 1157 411 1 0 763 0\n"
    File.should_receive(:read).with("/proc/self/statm").and_return(statm_file)

    system_call = mock(Oink::SystemCall, :stdout => "4096\n", :success? => true)
    Oink::SystemCall.should_receive(:execute).with('getconf PAGESIZE').and_return(system_call)
    Oink::StatmMemorySnapshot.new.memory.should == (pages * 4)
  end

  it "falls back to a 4096 if getconf PAGESIZE is not available" do
    pages = 6271
    statm_file = "#{pages} 1157 411 1 0 763 0\n"
    File.should_receive(:read).with("/proc/self/statm").and_return(statm_file)
    system_call = mock(Oink::SystemCall, :stdout => "", :success? => false)
    Oink::SystemCall.should_receive(:execute).with('getconf PAGESIZE').and_return(system_call)
    Oink::StatmMemorySnapshot.new.memory.should == (pages * 4)
  end
end

describe Oink::MemorySnapshot do
    describe "get_memory_usage" do
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