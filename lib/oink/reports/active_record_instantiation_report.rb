require "date"
require "oink/reports/base"
require "oink/reports/active_record_instantiation_oinked_request"
require "oink/reports/priority_queue"

module Oink
  module Reports
    class ActiveRecordInstantiationReport < Base

      def print(output)
        output.puts "---- OINK FOR ACTIVERECORD ----"
        output.puts "THRESHOLD: #{@threshold} Active Record objects per request\n"

        output.puts "\n-- REQUESTS --\n" if @format == :verbose

        @inputs.each do |input|
          input.each_line do |line|
            line = line.strip

             # Skip this line since we're only interested in the Hodel 3000 compliant lines
            next unless line =~ HODEL_LOG_FORMAT_REGEX

            if line =~ /rails\[(\d+)\]/
              pid = $1
              @pids[pid] ||= { :buffer => [], :ar_count => -1, :action => "", :request_finished => true }
              @pids[pid][:buffer] << line
            end

            if line =~ /Oink Action: ((\w+)#(\w+))/

              @pids[pid][:action] = $1
              unless @pids[pid][:request_finished]
                @pids[pid][:buffer] = [line]
              end
              @pids[pid][:request_finished] = false

            elsif line =~ /Instantiation Breakdown: Total: (\d+)/

              @pids[pid][:ar_count] = $1.to_i

            elsif line =~ /Oink Log Entry Complete/

              if @pids[pid][:ar_count] > @threshold
                @bad_actions[@pids[pid][:action]] ||= 0
                @bad_actions[@pids[pid][:action]] = @bad_actions[@pids[pid][:action]] + 1
                date = HODEL_LOG_FORMAT_REGEX.match(line).captures[0]
                @bad_requests.push(ActiveRecordInstantiationOinkedRequest.new(@pids[pid][:action], date, @pids[pid][:buffer], @pids[pid][:ar_count]))
                if @format == :verbose
                  @pids[pid][:buffer].each { |b| output.puts b }
                  output.puts "---------------------------------------------------------------------"
                end
              end

              @pids[pid][:request_finished] = true
              @pids[pid][:buffer] = []
              @pids[pid][:ar_count] = -1

            end # end elsif
          end # end each_line
        end # end each input

        print_summary(output)

      end
    end
  end
end