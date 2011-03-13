require "rspec"
require "ostruct"
require "logger"

dir = File.dirname(__FILE__)
require File.join(dir, "/../lib/oink.rb")
require "oink/rails/instance_type_counter"
require "oink/rails/memory_usage_logger"

require 'helpers/database'
require 'fakes/fake_application_controller'
require 'fakes/psuedo_output'

RSpec.configure do |config|

  config.before :suite do
    setup_memory_database
    Pig = Class.new(ActiveRecord::Base)
    Pen = Class.new(ActiveRecord::Base)
    Pig.belongs_to :pen
  end

end