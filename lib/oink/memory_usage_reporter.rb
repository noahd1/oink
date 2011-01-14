require "date"
require "oink/base"
require "oink/oinked_request/oinked_memory_request"
require "oink/priority_queue"

module Oink

  class MemoryUsageReporter < Base
    def print(output)
      output.puts "---- MEMORY THRESHOLD ----"
      output.puts "THRESHOLD: #{@threshold/1024} MB\n"
    
      output.puts "\n-- REQUESTS --\n" if @format == :verbose
    
      @inputs.each do |input|
        input.each_line do |line|
          line = line.strip
          
          # Skip this line since we're only interested in the Hodel 3000 compliant lines
          # Also skip lines that have the wrong character encoding
          begin
            next unless line =~ HODEL_LOG_FORMAT_REGEX
          rescue => e
            output.puts "\nSkipping malformed line" if @format == :verbose and e =~ /invalid byte sequence/
            next
          end

          if line =~ /rails\[(\d+)\]/
            pid = $1
            @pids[pid] ||= { :buffer => [], :last_memory_reading => -1, :current_memory_reading => -1, :action => "", :request_finished => true }
            @pids[pid][:buffer] << line
          end

          if line =~ /Processing ((\w+)#(\w+)) /
      
            unless @pids[pid][:request_finished]
              @pids[pid][:last_memory_reading] = -1
            end
            @pids[pid][:action] = $1
            @pids[pid][:request_finished] = false
      
          elsif line =~ /Memory usage: (\d+) /
      
            memory_reading = $1.to_i
            @pids[pid][:current_memory_reading] = memory_reading
      
          elsif line =~ /Completed in/
        
            @pids[pid][:request_finished] = true
            unless @pids[pid][:current_memory_reading] == -1 || @pids[pid][:last_memory_reading] == -1
              memory_diff = @pids[pid][:current_memory_reading] - @pids[pid][:last_memory_reading]
              if memory_diff > @threshold
                @bad_actions[@pids[pid][:action]] ||= 0
                @bad_actions[@pids[pid][:action]] = @bad_actions[@pids[pid][:action]] + 1
                date = HODEL_LOG_FORMAT_REGEX.match(line).captures[0]
                @bad_requests.push(OinkedMemoryRequest.new(@pids[pid][:action], date, @pids[pid][:buffer], memory_diff))
                if @format == :verbose
                  @pids[pid][:buffer].each { |b| output.puts b } 
                  output.puts "---------------------------------------------------------------------"
                end
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
