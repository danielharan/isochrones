require 'rubygems'
require 'fastercsv'
require 'ostruct'

class Mapper
  attr_accessor :trips, :stop_times, :best_times
  def initialize(feed_dir)
    load_data(feed_dir)
  end
  
  def load_data(feed_dir)
    @trips      = Trip.load      "#{feed_dir}/trips.txt"
    @stop_times = StopTime.load  "#{feed_dir}/stop_times.txt"
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