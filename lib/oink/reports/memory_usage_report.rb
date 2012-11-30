require "date"
require "oink/reports/base"
require "oink/reports/memory_oinked_request"
require "oink/reports/priority_queue"

module Oink
  module Reports
    class MemoryUsageReport < Base
      def print(output)
        output.puts "---- MEMORY THRESHOLD ----"
        output.puts "THRESHOLD: #{@threshold/1024} MB\n"

        output.puts "\n-- REQUESTS --\n" if @format == :verbose

        @inputs.each do |input|
          input.each_line do |line|
            line = line.strip

             # Skip this line since we're only interested in the Hodel 3000 compliant lines
            next unless line =~ HODEL_LOG_FORMAT_REGEX

            if line =~ /rails\[(\d+)\]/
              pid = $1
              @pids[pid] ||= { :buffer => [], :last_memory_reading => -1, :current_memory_reading => -1, :action => "", :request_finished => true }
              @pids[pid][:buffer] << line
            end

            if line =~ /Oink Action: (([\w\/]+)#(\w+))/

              unless @pids[pid][:request_finished]
                @pids[pid][:last_memory_reading] = -1
              end
              @pids[pid][:action] = $1
              @pids[pid][:request_finished] = false

            elsif line =~ /Memory usage: (\d+) /

              memory_reading = $1.to_i
              @pids[pid][:current_memory_reading] = memory_reading

            elsif line =~ /Oink Log Entry Complete/

              @pids[pid][:request_finished] = true
              unless @pids[pid][:current_memory_reading] == -1 || @pids[pid][:last_memory_reading] == -1
                memory_diff = @pids[pid][:current_memory_reading] - @pids[pid][:last_memory_reading]
                if memory_diff > @threshold
                  @bad_actions[@pids[pid][:action]] ||= 0
                  @bad_actions[@pids[pid][:action]] = @bad_actions[@pids[pid][:action]] + 1
                  date = HODEL_LOG_FORMAT_REGEX.match(line).captures[0]
                  @bad_requests.push(MemoryOinkedRequest.new(@pids[pid][:action], date, @pids[pid][:buffer], memory_diff))
                  if @format == :verbose
                    @pids[pid][:buffer].each { |b| output.puts b }
                    output.puts "---------------------------------------------------------------------"
                  end
                  @bad_actions_averaged[@pids[pid][:action]] ||= []
                  @bad_actions_averaged[@pids[pid][:action]] << memory_diff
                end
              end

              @pids[pid][:buffer] = []
              @pids[pid][:last_memory_reading] = @pids[pid][:current_memory_reading]
              @pids[pid][:current_memory_reading] = -1

            end # end elsif
          end # end each_line
        end # end each input

        print_summary(output)

      end
    end
  end
end
