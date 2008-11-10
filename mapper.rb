require 'rubygems'
require 'fastercsv'
require 'ostruct'

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

class FeedObject < OpenStruct
  def self.load(path)
    FasterCSV.read(path, :headers => true).collect { |line| new(line.to_hash) }
  end
end

class Trip < FeedObject
end

class StopTime < FeedObject
end