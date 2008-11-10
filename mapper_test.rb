require 'test/unit'
require 'mapper'
require 'rubygems'


class MapperTest < Test::Unit::TestCase
  
  def test_initialize
    m = Mapper.new('sample-feed')
    assert_not_nil m.trips
    assert_not_nil m.stop_times
  end
end

class TripTest < Test::Unit::TestCase
  def test_load
    assert_equal 11, (trips = Trip.load("sample-feed/trips.txt")).size
    
    t = trips.first
    assert_equal ['AB', 'FULLW', 'AB1'], [t.route_id, t.service_id, t.trip_id]
  end
end

class StopTimeTest < Test::Unit::TestCase
  def test_load
    stop_time = StopTime.load("sample-feed/stop_times.txt").first
    
    assert_equal 'STBA', stop_time.trip_id
  end
end