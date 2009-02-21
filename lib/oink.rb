$:.unshift(File.dirname(__FILE__ + '.rb') + '/../lib') unless $:.include?(File.dirname(__FILE__ + '.rb') + '/../lib')

require "oink/oink_for_memory"
require "oink/oink_for_active_record"
require "oink/cli"