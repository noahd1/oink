$:.unshift(File.dirname(__FILE__ + '.rb') + '/../lib') unless $:.include?(File.dirname(__FILE__ + '.rb') + '/../lib')

require "oink/memory_usage_reporter"
require "oink/active_record_instantiation_reporter"
require "oink/cli"