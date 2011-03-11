module Oink
  module HashUtils

    def self.to_sorted_array(hsh)
      hsh.sort{ |a, b| b[1] <=>a [1] }.collect { |k,v| "#{k}: #{v}" }
    end

  end
end