require "date"
require File.expand_path(File.dirname(__FILE__) + "/oink/logged_request/logged_memory_request")
require File.expand_path(File.dirname(__FILE__) + "/oink/priority_queue/priority_queue")

class OinkForMemory
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
  
  def each_line
    yield "---- MEMORY THRESHOLD ----"
    yield "THRESHOLD: #{@threshold/1024} MB\n"
    
    yield "\n-- REQUESTS --\n" if @format == :verbose
    
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
                @pids[pid][:buffer].each { |b| yield b } 
                yield "---------------------------------------------------------------------"
              end
            end
          end
          
          @pids[pid][:buffer] = []
          @pids[pid][:last_memory_reading] = @pids[pid][:current_memory_reading]
          @pids[pid][:current_memory_reading] = -1
        
        end # end elsif
      end # end each_line
    end # end each input

    yield "\n-- SUMMARY --\n"
    yield "Worst Requests:"
    @bad_requests.each_with_index do |offender, index|
      yield "#{index + 1}. #{offender.datetime}, #{offender.memory} KB, #{offender.action}"
      if @format == :summary
        offender.log_lines.each { |b| yield b } 
        yield "---------------------------------------------------------------------"
      end
    end
    yield "\nWorst Actions:"
    @bad_actions.sort{|a,b| b[1]<=>a[1]}.each { |elem|
      yield "#{elem[1]}, #{elem[0]}"
    }
    
  end

end