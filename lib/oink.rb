require "date"
require File.expand_path(File.dirname(__FILE__) + "/logged_request")
require File.expand_path(File.dirname(__FILE__) + "/priority_queue")

class Oink
  VERSION = '0.1.0'
  FORMATS = %w[verbose short-summary summary]
  FORMAT_ALIASES = { "v" => "verbose", "ss" => "short-summary", "s" => "summary" }
  
  def initialize(input, threshold, options = {})
    @inputs = Array(input)
    @threshold = threshold
    @format = options[:format] || :short_summary
    
    @pids = {}
    @oinkers = {}
    @worst_offenses = PriorityQueue.new(10)
    @earliest = nil
    @latest = nil
  end
  
  def each_line
    yield "Actions using over #{@threshold/1024} MB in single request:"
    
    @inputs.each do |input|
      input.each_line do |line|
        line = line.strip

        if line =~ /rails\[(\d+)\]/
          pid = $1

          unless @pids[pid]
            @pids[pid] = { :buffer => [], :last_memory_reading => -1, :current_memory_reading => -1, :action => "", :request_finished => true }
          end
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
              @oinkers[@pids[pid][:action]] ||= 0
              @oinkers[@pids[pid][:action]] = @oinkers[@pids[pid][:action]] + 1
              date = /^(\w+ \d{2} \d{2}:\d{2}:\d{2})/.match(line).captures[0]
              @worst_offenses.push(LoggedRequest.new(@pids[pid][:action], date, memory_diff, @pids[pid][:buffer]))
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
    
    yield "From #{@earliest.strftime('%m %d %Y')} to #{@latest.strftime('%m %d %Y')}" if @earliest && @latest
    yield "-- SUMMARY --"
    yield "Rank of Single Time Worst Offenders"
    @worst_offenses.each_with_index do |offender, index|
      yield "#{index + 1}. #{offender.datetime}, #{offender.memory} KB, #{offender.action}"
      if @format == :summary
        offender.log_lines.each { |b| yield b } 
        yield "---------------------------------------------------------------------"
      end
    end
    yield "# of Times, Action"
    @oinkers.sort{|a,b| b[1]<=>a[1]}.each { |elem|
      yield "#{elem[1]}, #{elem[0]}"
    }
  end

end