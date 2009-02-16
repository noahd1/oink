require "rubygems"
require "spec"

$:.unshift(File.dirname(__FILE__ + '.rb') + '/../lib') unless $:.include?(File.dirname(__FILE__ + '.rb') + '/../lib')
require "oink"

class PsuedoOutput < Array
  
  def puts(line)
    self << line
  end
  
end