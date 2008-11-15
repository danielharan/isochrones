require 'rubygems'
require 'fastercsv'
require 'ostruct'
require 'active_support'

class Mapper
  attr_accessor :trips, :stop_times, :stops, :best_times
  def initialize(feed_dir)
    load_data(feed_dir)
    
    # structure the graph data in a way that we can use
    Stop.generate_hops(@stops, @stop_times)
  end
  
  def load_data(feed_dir)
    @trips      = Trip.load      "#{feed_dir}/trips.txt"
    @stop_times = StopTime.load  "#{feed_dir}/stop_times.txt"
    @stops      = Stop.load      "#{feed_dir}/stops.txt"
  end
  
  def isochrone(stop, time)
    @best_times = {stop => time}
    @stack = [stop]
    while !@stack.empty?
      traverse(@stack.pop, time)
    end
  end
  
  private
    def traverse(stop,time)
      stop.available_hops.each do |hop|
        if @best_times[hop.destination_stop] > hop.end_time
          @best_times[hop.destination_stop] = hop.end_time
          @stack << hop.destination_stop
        end
      end
    end
end

class FeedObject < OpenStruct
  def self.load(path)
    FasterCSV.read(path, :headers => true).collect { |line| new(line.to_hash) }
  end
end

class Trip     < FeedObject; end
class StopTime < FeedObject; end

class Hop < OpenStruct
  def initialize(from,to)
    super :departure_time => from.departure_time, :arrival_time => to.arrival_time,
          :trip_id => from.trip_id, :destination => to.stop_id
  end
end

class Stop     < FeedObject
  attr_accessor :available_hops
  
  def initialize(args)
    super(args)
    @available_hops = []
  end
  
  def self.generate_hops(stops,stop_times)
    stops = stops.inject({}) {|memo,stop| memo[stop.stop_id] = stop; memo }
    
    stop_times.group_by {|st| st.trip_id}.each do |trip_id,trip_stops|
      trip_stops = trip_stops.sort_by(&:stop_sequence)
      
      (by_pair = trip_stops.zip(trip_stops[1..-1])).pop
      by_pair.each do |from,to|
        stops[from.stop_id].available_hops << Hop.new(from,to)
      end
    end
  end
end
