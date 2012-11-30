require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

module Oink::Reports
  describe MemoryUsageReport do

    TEN_MEGS = 10 * 1024

    describe "short summary with frequent offenders" do

      it "should report actions which exceed the threshold once" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        MemoryUsageReport.new(io, TEN_MEGS).print(output)
        output.should include("1, Media#show")
      end

      it "should not report actions which do not exceed the threshold" do
        threshold = 10

        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        MemoryUsageReport.new(io, TEN_MEGS).print(output)
        output.should_not include("1, Media#show")
      end

      it "should report actions which exceed the threshold multiple times" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{(TEN_MEGS * 2) + 2} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        MemoryUsageReport.new(io, TEN_MEGS).print(output)
        output.should include("2, Media#show")
      end

      it "should order actions by most exceeded" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{(TEN_MEGS * 2) + 2} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{(TEN_MEGS * 3) + 3} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        MemoryUsageReport.new(io, TEN_MEGS).print(output)
        output[8].should == "2, Media#show"
        output[9].should == "1, Users#show"
      end

      it "should not report actions which do not complete properly" do
        threshold = 10

        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        MemoryUsageReport.new(io, TEN_MEGS).print(output)
        output.should_not include("1, Media#show")
      end

      it "should not report actions from different pids" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[5513]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[5513]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[5513]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        MemoryUsageReport.new(io, TEN_MEGS).print(output)
        output.should_not include("1, Media#show")
      end

      describe "summary with top 10 offenses" do

        it "should only report requests over threshold" do
          str = <<-STR
          Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
          Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
          Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
          Feb 01 01:58:32 ey04-s00297 rails[4413]: Oink Action: Media#show
          Feb 01 01:58:33 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
          Feb 01 01:58:34 ey04-s00297 rails[4413]: Oink Log Entry Complete
          STR

          io = StringIO.new(str)
          output = PsuedoOutput.new
          MemoryUsageReport.new(io, TEN_MEGS).print(output)
          output.should include("1. Feb 01 01:58:34, #{TEN_MEGS + 1} KB, Media#show")
        end

        it "should not include requests which are not over the threshold" do
          str = <<-STR
          Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
          Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
          Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
          Feb 01 01:58:32 ey04-s00297 rails[4413]: Oink Action: Media#show
          Feb 01 01:58:33 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS} | PID: 4413
          Feb 01 01:58:34 ey04-s00297 rails[4413]: Oink Log Entry Complete
          STR

          io = StringIO.new(str)
          output = PsuedoOutput.new
          MemoryUsageReport.new(io, TEN_MEGS).print(output)
          output.should_not include("1. Feb 01 01:58:34, #{TEN_MEGS + 1} KB, Media#show")
        end

        it "should order offenses from biggest to smallest" do
          str = <<-STR
          Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
          Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
          Feb 01 01:58:31 ey04-s00297 rails[4413]: Oink Log Entry Complete
          Feb 01 01:58:32 ey04-s00297 rails[4413]: Oink Action: Media#show
          Feb 01 01:58:33 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
          Feb 01 01:58:34 ey04-s00297 rails[4413]: Oink Log Entry Complete
          Feb 01 01:58:35 ey04-s00297 rails[4413]: Oink Action: Details#show
          Feb 01 01:58:36 ey04-s00297 rails[4413]: Memory usage: #{(TEN_MEGS * 2) + 2} | PID: 4413
          Feb 01 01:58:37 ey04-s00297 rails[4413]: Oink Log Entry Complete
          STR

          io = StringIO.new(str)
          output = PsuedoOutput.new
          MemoryUsageReport.new(io, TEN_MEGS).print(output)
          output[4].should == "1. Feb 01 01:58:34, #{TEN_MEGS + 1} KB, Media#show"
          output[5].should == "2. Feb 01 01:58:37, #{TEN_MEGS + 1} KB, Details#show"
        end

      end

      # it "should report the time span" do
      #   str = <<-STR
      #   Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
      #   Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
      #   Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
      #   Mar 13 01:58:29 ey04-s00297 rails[5513]: Oink Action: Media#show
      #   Mar 13 01:58:30 ey04-s00297 rails[5513]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
      #   Mar 13 03:58:30 ey04-s00297 rails[5513]: Oink Log Entry Complete
      #   STR
      #
      #   io = StringIO.new(str)
      #   output = PsuedoOutput.new
      #   MemoryUsageReport.new(io, TEN_MEGS).each_line do |line|
      #     output << line
      #   end
      #   output.first.should == "Feb 01 01:58:29 - Mar 13 03:58:30"
      # end

    end

    describe "verbose format" do
      it "should print the full lines of actions exceeding the threshold" do
        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Parameters: {"id"=>"2332", "controller"=>"users"}
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Parameters: {"id"=>"22900", "controller"=>"media"}
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR
        io = StringIO.new(str)
        output = PsuedoOutput.new
        MemoryUsageReport.new(io, TEN_MEGS, :format => :verbose).print(output)
        output[3..6].should == str.split("\n")[4..7].map { |o| o.strip }
      end

      it "should handle actions which do not complete properly" do
        threshold = 10

        str = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Processing ActorController#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{(TEN_MEGS * 2) + 2} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io = StringIO.new(str)
        output = PsuedoOutput.new
        MemoryUsageReport.new(io, TEN_MEGS, :format => :verbose).print(output)
        output[3..5].should == str.split("\n")[6..8].map { |o| o.strip }
      end
    end

    describe "averaged format" do
      it "should correctly calculate the stats for the actions" do
        str = <<-STR
        Feb 01 01:59:29 ey04-s00297 rails[4413]: Processing Users#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:57:29 ey04-s00297 rails[4413]: Parameters: {"id"=>"2332", "controller"=>"users"}
        Feb 01 01:57:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 10} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:57:30 ey04-s00297 rails[4413]: Completed in 984ms (View: 840, DB: 4) | 200 OK
        Feb 01 01:59:29 ey04-s00297 rails[4413]: Processing Users#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Parameters: {"id"=>"22900", "controller"=>"media"}
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{(TEN_MEGS*3) + 40} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Completed in 984ms (View: 840, DB: 4) | 200 OK
        Feb 01 01:59:29 ey04-s00297 rails[4413]: Processing Users#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:59:29 ey04-s00297 rails[4413]: Parameters: {"id"=>"22900", "controller"=>"media"}
        Feb 01 01:59:30 ey04-s00297 rails[4413]: Memory usage: #{(TEN_MEGS*8) + 40} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:59:30 ey04-s00297 rails[4413]: Completed in 984ms (View: 840, DB: 4) | 200 OK
        STR
        io = StringIO.new(str)
        output = PsuedoOutput.new
        MemoryUsageReport.new(io, TEN_MEGS, :format => :averaged).print(output)
        output.last.should == "Users#show\t51200\t35855\t20510\t71710\t2"
      end
      it "should sort by the total memory increase" do
        str = <<-STR
        Feb 01 01:57:29 ey04-s00297 rails[4413]: Processing Users#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:57:29 ey04-s00297 rails[4413]: Parameters: {"id"=>"2332", "controller"=>"users"}
        Feb 01 01:57:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 10} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:57:30 ey04-s00297 rails[4413]: Completed in 984ms (View: 840, DB: 4) | 200 OK
        Feb 01 01:57:29 ey04-s00297 rails[4413]: Processing Users#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:57:29 ey04-s00297 rails[4413]: Parameters: {"id"=>"2332", "controller"=>"users"}
        Feb 01 01:57:30 ey04-s00297 rails[4413]: Memory usage: #{2*(TEN_MEGS + 10)} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:57:30 ey04-s00297 rails[4413]: Completed in 984ms (View: 840, DB: 4) | 200 OK
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Processing Users#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Parameters: {"id"=>"22900", "controller"=>"media"}
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{3*(TEN_MEGS + 10)} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Completed in 984ms (View: 840, DB: 4) | 200 OK
        Feb 01 02:57:29 ey04-s00297 rails[4413]: Processing Users2#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users2#show
        Feb 01 02:57:29 ey04-s00297 rails[4413]: Parameters: {"id"=>"2332", "controller"=>"users"}
        Feb 01 02:57:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 20} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 02:57:30 ey04-s00297 rails[4413]: Completed in 984ms (View: 840, DB: 4) | 200 OK
        Feb 01 02:58:29 ey04-s00297 rails[4413]: Processing Users2#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users2#show
        Feb 01 02:58:29 ey04-s00297 rails[4413]: Parameters: {"id"=>"22900", "controller"=>"media"}
        Feb 01 02:58:30 ey04-s00297 rails[4413]: Memory usage: #{2*(TEN_MEGS + 20)} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 02:58:30 ey04-s00297 rails[4413]: Completed in 984ms (View: 840, DB: 4) | 200 OK
        STR
        io = StringIO.new(str)
        output = PsuedoOutput.new
        MemoryUsageReport.new(io, TEN_MEGS, :format => :averaged).print(output)
        output[12].should include('Users#show')
        output[13].should include('Users2#show')
      end
    end

    describe "multiple io streams" do
      it "should accept multiple files" do

        str1 = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        str2 = <<-STR
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Users#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: 0 | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        Feb 01 01:58:29 ey04-s00297 rails[4413]: Oink Action: Media#show
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Memory usage: #{TEN_MEGS + 1} | PID: 4413
        Feb 01 01:58:30 ey04-s00297 rails[4413]: Oink Log Entry Complete
        STR

        io1 = StringIO.new(str1)
        io2 = StringIO.new(str2)
        output = PsuedoOutput.new
        MemoryUsageReport.new([io1, io2], TEN_MEGS).print(output)
        output.should include("2, Media#show")
      end

    end

  end
end
