module Oink
  module Reports
    class Base

      FORMATS = %w[verbose short-summary summary]
      FORMAT_ALIASES = { "v" => "verbose", "ss" => "short-summary", "s" => "summary" }
      HODEL_LOG_FORMAT_REGEX = /^(\w+ \d{2} \d{2}:\d{2}:\d{2})/

      def initialize(input, threshold, options = {})
        @inputs = Array(input)
        @threshold = threshold
        @format = options[:format] || :short_summary

        @pids = {}
        @bad_actions = {}
        @bad_actions_averaged = {}
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
        output.puts "\nAggregated Totals:\n"
        if @bad_actions_averaged.length > 0
          action_stats =  @bad_actions_averaged.map { |action,values|
            total = values.inject(0){ |sum,x| sum+x }
            {
              :action => action,
              :total => total,
              :mean => total/values.length,
              :max => values.max,
              :min => values.min,
              :count => values.length,
            }
          }
          action_width = @bad_actions_averaged.keys.map{|k| k.length}.max
          output.puts "#{'Action'.ljust(action_width)}\tMax\tMean\tMin\tTotal\tNumber of requests"
          action_stats.sort{|a,b| b[:total]<=>a[:total]}.each do |action_stat|
            output.puts "#{action_stat[:action].ljust(action_width)}\t#{action_stat[:max]}\t#{action_stat[:mean]}\t#{action_stat[:min]}\t#{action_stat[:total]}\t#{action_stat[:count]}"
          end
        end
      end
    end
  end
end
