require 'rubygems'
require 'fastercsv'

class Mapper
  FEED_DIR = 'sample-feed'
  
  attr_accessor :trips, :stop_times, :best_times
  def initialize
    load_trips
    load_stop_times
    @best_times = {}
  end
  
  def load_trips
    @trips = Trip.load("#{FEED_DIR}/trips.txt")
  end
  
  def load_stop_times
    @stop_times = FasterCSV.read("#{FEED_DIR}/stop_times.txt").to_a[1..-1]
  end
  
  def isochrone(stop, time)
    @best_times[stop] = time
    @stack = [stop]
    while !@stack.empty?
      traverse(stop.pop, time)
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

class FeedObject
  def self.load(path)
    FasterCSV.read(path).to_a[1..-1].collect {|line| new(line) }
  end
end

class Trip < FeedObject
  attr_accessor 'route_id','service_id','trip_id','trip_headsign','direction_id','block_id','shape_id'
  
  def initialize(args)
    @route_id, @service_id, @trip_id, @trip_headsign, ignored = *args
  end
end

class StopTime < FeedObject
  attr_accessor 'trip_id', 'arrival_time', 'departure_time', 'stop_id', 'stop_sequence', 'stop_headsign'
  
  def initialize(args)
    @trip_id, @arrival_time, @departure_time, @stop_id, @stop_sequence, @stop_headsign, ignored = *args
  end
end