require "oink/reports/memory_usage_reporter"
require "oink/reports/active_record_instantiation_reporter"
require 'oink/utils/hash_utils'
require "oink/cli"

if defined?(Rails)
  require 'oink/rails'
end
