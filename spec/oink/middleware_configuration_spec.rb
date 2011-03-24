require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require "oink/middleware"
require 'rack/test'

describe "Oink::Middleware configuration" do
  include Rack::Test::Methods

  class SampleApplication
    def call(env)
      [200, {}, ""]
    end
  end

  let(:app)         { Oink::Middleware.new(SampleApplication.new, oink_configuration) }
  let(:oink_configuration) { @oink_configuration || {} }

  context "log_path option" do
    before do
      Oink::Instrumentation::MemorySnapshot.stub(:memory => 4092)
      FileUtils.mkdir_p("log")
    end

    after do
      FileUtils.remove_dir("log")
    end

    it "writes to the default log path when not specified" do
      get "/"
      File.should exist(Oink::Middleware::DEFAULT_LOG_PATH)
    end

    it "writes to the log path specified" do
      @oink_configuration = {:log_path => "log/custom_path.log"}
      get "/"
      File.should exist("log/custom_path.log")
    end
  end

  context "instruments options" do
    before do
      @log_output = StringIO.new
      Hodel3000CompliantLogger.stub(:new => Hodel3000CompliantLogger.new(@log_output))
      Oink::Instrumentation::MemorySnapshot.stub(:memory => 4092)
    end

    context "with the memory instrument specified" do
      before do
        @oink_configuration = { :instruments => [:memory] }
      end

      it "does log memory usage" do
        get "/"
        @log_output.string.should include("Memory usage: 4092 | PID: #{$$}")
      end

      it "does not log activerecord objects instantiated" do
        get "/"
        @log_output.string.should_not include("Instantiation Breakdown:")
      end

      it "does not monkeypatch activerecord" do
        ActiveRecord::Base.should_not_receive(:include)
        get "/"
      end
    end

    context "with the activerecord instrument specified" do
      before do
        @oink_configuration = { :instruments => [:activerecord] }
        get "/"
      end

      it "does not log memory usage" do
        @log_output.string.should_not include("Memory usage:")
      end

      it "does log activerecord objects instantiated" do
        @log_output.string.should include("Instantiation Breakdown:")
      end
    end
  end
end