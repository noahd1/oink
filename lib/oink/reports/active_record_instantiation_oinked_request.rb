require "oink/reports/request"

module Oink
  module Reports
    class ActiveRecordInstantiationOinkedRequest < Request

      def display_oink_number
        @oink_number
      end

    end
  end
end