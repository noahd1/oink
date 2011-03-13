require "oink/reports/request"

module Oink
  module Reports
    class MemoryOinkedRequest < Request

      def display_oink_number
        "#{@oink_number} KB"
      end

    end
  end
end