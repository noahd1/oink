require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Oink do

  # describe "short summary with frequent offenders" do
  # 
  #   it "should report actions which exceed the threshold once" do
  #     str = <<-STR
  #     Feb 01 01:58:29 ey04-s00297 rails[4413]: Processing Users#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
  #     Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiated 51 ActiveRecord objects
  #     Feb 01 01:58:31 ey04-s00297 rails[4413]: Completed in 984ms (View: 840, DB: 4) | 200 OK
  #     STR
  # 
  #     io = StringIO.new(str)
  #     output = []
  #     Oink.new(io, :ar_threshold => 50).each_line do |line|
  #       output << line
  #     end
  #     output.should include("1, Users#show")
  #   end
  # end


  # it "should not report actions which do not exceed the threshold" do
  #   str = <<-STR
  #   Feb 01 01:58:29 ey04-s00297 rails[4413]: Processing Users#show (for 92.84.151.171 at 2009-02-01 01:58:29) [GET]
  #   Feb 01 01:58:30 ey04-s00297 rails[4413]: Instantiated 50 ActiveRecord objects
  #   Feb 01 01:58:31 ey04-s00297 rails[4413]: Completed in 984ms (View: 840, DB: 4) | 200 OK
  #   STR
  # 
  #   io = StringIO.new(str)
  #   output = []
  #   Oink.new(io, :ar_threshold => 50).each_line do |line|
  #     output << line
  #   end
  #   output.should_not include("1, Users#show")
  # end


end
