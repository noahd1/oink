require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require "rspec"
require "ostruct"
require "logger"

require 'helpers/database'
require 'fakes/fake_application_controller'
require 'fakes/psuedo_output'

require 'oink/cli'
require 'oink/rails'

RSpec.configure do |config|

  config.before :suite do
    setup_memory_database
    Pig = Class.new(ActiveRecord::Base)
    Pen = Class.new(ActiveRecord::Base)
    Pig.belongs_to :pen
  end

end
