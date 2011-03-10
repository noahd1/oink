require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require "oink/integration/middleware"
require 'rack/test'
require 'logger'

describe Oink::Integration::Middleware do
  include Rack::Test::Methods

  class SampleApplication
    def call(env)
      case env['PATH_INFO']
      when "/do_nothing"
      when "/instantiate_pigs"
        Pig.create(:name => "Babe")
        Pig.first
      when "/instantiate_pigs_and_pens"
        Pig.create(:name => "Babe")
        Pen.create(:location => "Backyard")
        Pig.first
      end
      [200, {}, ""]
    end
  end

  let(:log_output)  { StringIO.new }
  let(:logger)      { Logger.new(log_output) }
  let(:app)         { Oink::Integration::Middleware.new(SampleApplication.new, logger) }

  it "reports 0 totals" do
    get "/do_nothing"
    log_output.string.should include("Instantiation Breakdown: Total: 0")
  end

  it "reports pigs instantiated" do
    get "/instantiate_pigs"
    log_output.string.should include("Instantiation Breakdown: Pig: 2 | Total: 2")
  end

  it "reports pigs and pens instantiated" do
    get "/instantiate_pigs_and_pens"
    log_output.string.should include("Instantiation Breakdown: Total: 3 | Pig: 2 | Pen: 1")
  end

end