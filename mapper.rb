require 'rubygems'
require 'fastercsv'

class Mapper
  FEED_DIR = 'sample-feed'
  
  attr_accessor :trips, :stop_times
  def initialize
    load_trips
    load_stop_times
  end
  
  def load_trips
    @trips = Trip.load("#{FEED_DIR}/trips.txt")
  end
  
  def load_stop_times
    @stop_times = FasterCSV.read("#{FEED_DIR}/stop_times.txt").to_a[1..-1]
  end
end


class FeedObject
  def self.load(path)
    FasterCSV.read(path).to_a[1..-1].collect {|line| new(line) }
  end
end

class Trip < FeedObject
  ['route_id','service_id','trip_id','trip_headsign','direction_id','block_id','shape_id'].each do |attr|
    attr_accessor attr.to_s
  end
  
  def initialize(args)
    @route_id, @service_id, @trip_id, @trip_headsign, ignored = *args
  end
end

class StopTime < FeedObject
  %w{ trip_id arrival_time departure_time stop_id stop_sequence stop_headsign }.each {|attr| attr_accessor attr }
  
  def initialize(args)
    
  end
end