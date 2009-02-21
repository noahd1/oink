require "rubygems"
require "spec"

require File.dirname(__FILE__) + "/../lib/oink.rb"

class PsuedoOutput < Array
  
  def puts(line)
    self << line
  end
  
end