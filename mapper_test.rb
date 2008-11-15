require 'test/unit'
require 'mapper'
require 'rubygems'
require 'activesupport'

class MapperTest < Test::Unit::TestCase
  
  def test_initialize
    m = Mapper.new('sample-feed')
    assert_not_nil m.trips
    assert_not_nil m.stop_times
    assert_not_nil m.stops
  end
  
  def test_hop_creation
    m = Mapper.new('sample-feed')
    assert_equal 2, m.stop("STAGECOACH").available_hops.length
    
    stba_hop = m.stop("STAGECOACH").available_hops.detect {|hop| hop.trip_id == "STBA"}
    assert_equal "BEATTY_AIRPORT", stba_hop.destination
    assert_equal "6:20:00",        stba_hop.arrival_time
    
    assert_equal "NANAA", m.stop("STAGECOACH").available_hops.detect {|hop| hop.trip_id == "CITY1"}.destination
  end
  
  def test_isochrone_creation
    m = Mapper.new('sample-feed')
    nanaa = m.stop("NANAA")
    # This is the default trip that Google's demo agency shows...
    # http://www.google.com/maps?ttype=dep&saddr=North+Ave+at+N+A+Ave+Beatty,+NV&daddr=W+Cottonwood+Dr+at+A+Ave+S+Beatty,+NV&ie=UTF8&f=d&dirflg=r
    # 6:07am	Depart North Ave / N A Ave (Demo)
    # 6:26am	Arrive E Main St / S Irving St (Demo)
    assert_equal "6:26:00", m.isochrone(nanaa, "6:07:00")["EMSI"]
  end
  
  def test_available_hops_are_after_current_time
    flunk # next TODO :)
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

class HopTest < Test::Unit::TestCase
  def test_initialize
    from = StopTime.new :stop_sequence => 1, :arrival_time => "6:00:00", :departure_time => "6:01:00",
                        :stop_id => "STAGECOACH", :trip_id => "STBA"
    to   = StopTime.new :stop_sequence => 2, :arrival_time => "6:20:00", :departure_time => "6:21:00",
                        :stop_id => "BEATTY_AIRPORT", :trip_id => "STBA"
    hop = Hop.new(from,to)
    assert_equal "6:01:00",        hop.departure_time
    assert_equal "6:20:00",        hop.arrival_time
    assert_equal "STBA",           hop.trip_id
    assert_equal "BEATTY_AIRPORT", hop.destination
  end
end