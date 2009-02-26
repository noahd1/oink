module Oink

  class Base

    VERSION = '0.1.0'
    FORMATS = %w[verbose short-summary summary]
    FORMAT_ALIASES = { "v" => "verbose", "ss" => "short-summary", "s" => "summary" }

    def initialize(input, threshold, options = {})
      @inputs = Array(input)
      @threshold = threshold
      @format = options[:format] || :short_summary
  
      @pids = {}
      @bad_actions = {}
      @bad_requests = PriorityQueue.new(10)
    end

  protected

    def print_summary(output)
      output.puts "\n-- SUMMARY --\n"
      output.puts "Worst Requests:"
      @bad_requests.each_with_index do |offender, index|
        output.puts "#{index + 1}. #{offender.datetime}, #{offender.display_oink_number}, #{offender.action}"
        if @format == :summary
          offender.log_lines.each { |b| output.puts b } 
          output.puts "---------------------------------------------------------------------"
        end
      end
      output.puts "\nWorst Actions:"
      @bad_actions.sort{|a,b| b[1]<=>a[1]}.each { |elem|
        output.puts "#{elem[1]}, #{elem[0]}"
      }
    end

  end
  
end