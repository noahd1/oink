require "oink/oinked_request/oinked_request"

class OinkedMemoryRequest < OinkedRequest
  
  def display_oink_number
    "#{@oink_number} KB"
  end
  
end