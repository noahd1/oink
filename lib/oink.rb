require "oink/memory_usage_reporter"
require "oink/active_record_instantiation_reporter"
require 'oink/hash_utils'
require "oink/cli"

if defined?(Rails)
  require 'oink/rails'
end
