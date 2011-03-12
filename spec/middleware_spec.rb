require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "oink/middleware"
require 'rack/test'
require 'logger'

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
  let(:logger)      { Logger.new(log_output) }
  let(:app)         { Oink::Middleware.new(SampleApplication.new, logger) }

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

end