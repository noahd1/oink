require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

module Oink
  module Instrumentation

    describe StatmMemorySnapshot do

      before do
        StatmMemorySnapshot.unset_statm_page_size
      end

      it "returns memory when pagesize is 4096" do
        pages = 6271
        statm_file = "#{pages} 1157 411 1 0 763 0\n"
        File.should_receive(:read).with("/proc/self/statm").and_return(statm_file)

        system_call = mock(SystemCall, :stdout => "4096\n", :success? => true)
        SystemCall.should_receive(:execute).with('getconf PAGESIZE').and_return(system_call)
        StatmMemorySnapshot.new.memory.should == (pages * 4)
      end

      it "falls back to a 4096 if getconf PAGESIZE is not available" do
        pages = 6271
        statm_file = "#{pages} 1157 411 1 0 763 0\n"
        File.should_receive(:read).with("/proc/self/statm").and_return(statm_file)
        system_call = mock(SystemCall, :stdout => "", :success? => false)
        SystemCall.should_receive(:execute).with('getconf PAGESIZE').and_return(system_call)
        StatmMemorySnapshot.new.memory.should == (pages * 4)
      end
    end

    describe SmapsMemorySnapshot do

      it "returns a sum of the sizes in the /proc/$$/smaps file" do
        proc_file = <<-STR
            Header

            Size: 25
            Size: 13 trailing

      leading Size: 4

            Footer

            STR
        File.should_receive(:new).with("/proc/#{$$}/smaps").and_return(proc_file)
        SmapsMemorySnapshot.new.memory.should == 42
      end

    end

    describe ProcessStatusMemorySnapshot do
      it "returns the result of a PS command" do
        system_call = mock(SystemCall, :stdout => "915")
        SystemCall.should_receive(:execute).with("ps -o vsz= -p #{$$}").and_return(system_call)
        ProcessStatusMemorySnapshot.new.memory.should == 915
      end

      describe "#available?" do
        it "returns true if ps succeeds" do
          system_call = mock(SystemCall, :success? => true)
          SystemCall.should_receive(:execute).with("ps -o vsz= -p #{$$}").and_return(system_call)
          ProcessStatusMemorySnapshot.available?.should be_true
        end
      end
    end

    describe MemorySnapshot do
      describe "#memory_snapshot_class" do
        it "raises an Oink::MemoryDataUnavailableError if not strategies can be found" do
          [WindowsMemorySnapshot, StatmMemorySnapshot, SmapsMemorySnapshot, ProcessStatusMemorySnapshot].each { |klass| klass.stub(:available? => false) }

          lambda { MemorySnapshot.memory_snapshot_class }.should raise_error(MemoryDataUnavailableError)
        end

        it "returns the first available memory snapshot strategy" do
          [WindowsMemorySnapshot, SmapsMemorySnapshot, ProcessStatusMemorySnapshot].each { |klass| klass.stub(:available? => false) }
          StatmMemorySnapshot.stub(:available? => true)
          MemorySnapshot.memory_snapshot_class.should == StatmMemorySnapshot
        end
      end
    end
  end
end