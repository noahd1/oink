require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

module Oink::Reports
  describe ActiveRecordInstantiationReport do

    describe "short summary with frequent offenders" do

      it "should report actions which exceed the threshold once" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 51 | User: 51
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new(io, 50).print(output)
        output.should include("1, Users#show")
      end

      it "should not report actions which do not exceed the threshold" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 50 | User: 50
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new(io, 50).print(output)
        output.should_not include("1, Users#show")
      end

      it "should report actions which exceed the threshold multiple times" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 51 | User: 51
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 51 | User: 51
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new(io, 50).print(output)
        output.should include("2, Users#show")
      end

      it "should order actions by most exceeded" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 51 | User: 51
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 51 | User: 51
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 51 | User: 51
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new(io, 50).print(output)
        output[8].should == "2, Media#show"
        output[9].should == "1, Users#show"
      end

      it "should not be bothered by incomplete requests" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 24 | User: 24
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 51 | User: 51
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new(io, 50).print(output)
        output.should include("1, Users#show")
      end

    end

    describe "summary with top 10 offenses" do

      it "should only report requests over threshold" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 51 | User: 51
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new(io, 50).print(output)
        output.should include("1. Feb 01 01:58:31, 51, Users#show")
      end

      it "should not include requests which are not over threshold" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 50 | User: 50
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new(io, 50).print(output)
        output.should_not include("1. Feb 01 01:58:31, 50, Users#show")
      end

      it "should order offenses from biggest to smallest" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Details#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 75 | User: 75
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:32 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:33 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 100 | User: 100
        Feb 01 01:58:34 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new(io, 50).print(output)
        output[4].should == "1. Feb 01 01:58:34, 100, Media#show"
        output[5].should == "2. Feb 01 01:58:31, 75, Details#show"
      end

    end

    describe "verbose format" do
      it "should print the full lines of actions exceeding the threshold" do
        str = <<-STR
        Feb 01 01:58:32 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:33 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 100 | User: 100
        Feb 01 01:58:34 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR
        io = StringIO.new(str)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new(io, 50, :format => :verbose).print(output)
        output[3..5].should == str.split("\n")[0..2].map { |o| o.strip }
      end

      it "should handle actions which do not complete properly" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 24 | User: 24
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 51 | User: 51
        Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new(io, 50, :format => :verbose).print(output)
        output[3..5].should == str.split("\n")[4..6].map { |o| o.strip }
      end
    end

    describe "multiple io streams" do
      it "should accept multiple files" do

        str1 = <<-STR
        Feb 01 01:58:32 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:33 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 100 | User: 100
        Feb 01 01:58:34 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        str2 = <<-STR
        Feb 01 01:58:32 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:33 ey04-s00297 rails[4413]: Instantiation Breakdown: Total: 100 | User: 100
        Feb 01 01:58:34 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io1 = StringIO.new(str1)
        io2 = StringIO.new(str2)
        output = PsuedoOutput.new
        ActiveRecordInstantiationReport.new([io1, io2], 50).print(output)
        output.should include("2, Media#show")
      end

    end


  end
end
