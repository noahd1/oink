require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require "oink/middleware"
require 'rack/test'

describe Oink::Middleware do
  include Rack::Test::Methods

  class SampleApplication
    def call(env)
      case env['PATH_INFO']
      when "/no_pigs"
      when "/two_pigs"
        Pig.create(:name => "Babe")
        Pig.first
      when "/two_pigs_in_a_pen"
        Pig.create(:name => "Babe")
        Pen.create(:location => "Backyard")
        Pig.first
      end
      [200, {}, ""]
    end
  end

  let(:log_output)  { StringIO.new }
  let(:logger)      { Hodel3000CompliantLogger.new(log_output) }
  let(:app)         { Oink::Middleware.new(SampleApplication.new, logger) }

  before do
    Oink::Instrumentation::MemorySnapshot.stub(:memory => 4092)
    Pig.delete_all
    Pen.delete_all
  end


  context "support legacy rails log format in transition to oink's own log format" do
    it "writes rails[pid] to the log even if the app isn't a rails app (for now)" do
      get "/no_pigs"
      log_output.string.should include("rails[#{$$}]")
    end

    it "writes 'Completed in' after the request has completed" do
      get "/no_pigs"
      log_output.string.should include("Completed in")
    end
  end

  it "reports 0 totals" do
    get "/no_pigs"
    log_output.string.should include("Instantiation Breakdown: Total: 0")
  end

  it "reports totals first even if it's a tie" do
    get "/two_pigs"
    log_output.string.should include("Instantiation Breakdown: Total: 2 | Pig: 2")
  end

  it "reports pigs and pens instantiated" do
    get "/two_pigs_in_a_pen"
    log_output.string.should include("Instantiation Breakdown: Total: 3 | Pig: 2 | Pen: 1")
  end

  it "logs memory usage" do
    Oink::Instrumentation::MemorySnapshot.should_receive(:memory).and_return(4092)
    get "/two_pigs_in_a_pen"
    log_output.string.should include("Memory usage: 4092 | PID: #{$$}")
  end

end