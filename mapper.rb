require 'rubygems'
require 'fastercsv'

class Mapper
  
  attr_accessor :routes
  def initialize
    load_routes
  end
  
  def load_routes
    @routes = Route.load("sample-feed/routes.txt")
  end
  
  def load_trips
    
  end
end

class Route
  ['route_id','agency_id','route_short_name','route_long_name',
   'route_desc','route_type','route_url','route_color','route_text_color'].each do |attr|
    attr_accessor attr.to_s
  end
  
  def initialize(*args)
    @route_id, @agency_id, @route_short_name, @route_long_name, ignored = *args
  end
  
  def self.load(path)
    FasterCSV.read(path).to_a[1..-1].collect do |line|
      Route.new(line)
    end
  end
end