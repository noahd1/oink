require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require "oink/integration/middleware"
require 'rack/test'

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

  def app
    Oink::Integration::Middleware.new(SampleApplication.new)
  end

  before do
    Oink::Integration::Middleware.logger = MemoryLogger.new
  end

  it "reports 0 totals" do
    get "/do_nothing"
    Oink::Integration::Middleware.logger.log.should include([:info, "Instantiation Breakdown: Total: 0"])
  end

  it "reports pigs instantiated" do
    get "/instantiate_pigs"
    Oink::Integration::Middleware.logger.log.should include([:info, "Instantiation Breakdown: Pig: 2 | Total: 2"])
  end

  it "reports pigs and pens instantiated" do
    get "/instantiate_pigs_and_pens"
    Oink::Integration::Middleware.logger.log.should include([:info, "Instantiation Breakdown: Total: 3 | Pig: 2 | Pen: 1"])
  end

end