require "date"
require "oink/oink"
require "oink/logged_request/logged_memory_request"
require "oink/priority_queue/priority_queue"

class OinkForMemory < Oink

  def print(output)
    output.puts "---- MEMORY THRESHOLD ----"
    output.puts "THRESHOLD: #{@threshold/1024} MB\n"
    
    output.puts "\n-- REQUESTS --\n" if @format == :verbose
    
    @inputs.each do |input|
      input.each_line do |line|
        line = line.strip

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
              date = /^(\w+ \d{2} \d{2}:\d{2}:\d{2})/.match(line).captures[0]
              @bad_requests.push(LoggedMemoryRequest.new(@pids[pid][:action], date, @pids[pid][:buffer], memory_diff))
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

    output.puts "\n-- SUMMARY --\n"
    output.puts "Worst Requests:"
    @bad_requests.each_with_index do |offender, index|
      output.puts "#{index + 1}. #{offender.datetime}, #{offender.memory} KB, #{offender.action}"
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