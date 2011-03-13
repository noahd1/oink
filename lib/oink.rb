require "oink/reports/memory_usage_report"
require "oink/reports/active_record_instantiation_report"
require 'oink/utils/hash_utils'
require "oink/cli"

if defined?(Rails)
  require 'oink/rails'
end
