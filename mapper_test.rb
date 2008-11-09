require 'test/unit'
require 'mapper'
require 'rubygems'


class MapperTest < Test::Unit::TestCase
  
  def test_initialize
    m = Mapper.new
    assert_not_nil m.trips
    assert_not_nil m.stop_times
  end
end

class TripTest < Test::Unit::TestCase
  def test_load
    assert_equal 11, (trips = Trip.load("sample-feed/trips.txt")).size
    
    assert_equal 'AB', trips.first.route_id
    assert_equal 'FULLW', trips.first.service_id
  end
end
