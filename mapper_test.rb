require 'test/unit'
require 'mapper'
require 'rubygems'
require 'activesupport'

class MapperTest < Test::Unit::TestCase
  
  def test_initialize
    m = MapperFactory.new('sample-feed').mapper(Date.new(2008, 11, 18))
    assert_not_nil m.trips
    assert_not_nil m.stop_times
    assert_not_nil m.stops
  end
  
  def test_hop_creation
    m = MapperFactory.new('sample-feed').mapper(Date.new(2008, 11, 18))
    assert_equal 2, m.stop("STAGECOACH").available_hops.length
    
    stba_hop = m.stop("STAGECOACH").available_hops.detect {|hop| hop.trip_id == "STBA"}
    assert_equal "BEATTY_AIRPORT",      stba_hop.destination.stop_id
    assert_equal Time.parse("6:20:00"), stba_hop.arrival_time
    
    assert_equal "NANAA", m.stop("STAGECOACH").available_hops.detect {|hop| hop.trip_id == "CITY1"}.destination.stop_id
  end
  
  def test_isochrone_creation
    m = MapperFactory.new('sample-feed').mapper(Date.new(2008, 11, 18))
    nanaa = m.stop("NANAA")
    assert_not_nil nanaa
    # This is the default trip that Google's demo agency shows...
    # http://www.google.com/maps?ttype=dep&saddr=North+Ave+at+N+A+Ave+Beatty,+NV&daddr=W+Cottonwood+Dr+at+A+Ave+S+Beatty,+NV&ie=UTF8&f=d&dirflg=r
    # 6:07am	Depart North Ave / N A Ave (Demo)
    # 6:26am	Arrive E Main St / S Irving St (Demo)
    isochrone = m.isochrone(nanaa, Time.parse("6:07:00"))
    assert_equal Time.parse("6:26:00"), isochrone[m.stop("EMSI")]
    assert_equal Time.parse("6:07:00"), isochrone[nanaa], "should not be able to get to departure stop before we left"
    #puts isochrone.collect {|key,val| [key.stop_id, val]}.sort_by(&:last).inspect
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
    # STBA,6:00:00,6:00:00,STAGECOACH,1,,,,
    
    assert_equal 'STBA', stop_time.trip_id
    assert_equal Time.parse('6:00:00'), stop_time.departure_time
    assert_equal Time.parse('6:00:00'), stop_time.arrival_time
  end
end

class StopTest < Test::Unit::TestCase
  def test_available_hops_are_after_current_time
    # Check service on weekend, because not all service is available on weekdays
    m = MapperFactory.new('sample-feed').mapper(Date.new(2008, 11, 16)) # Sunday
    stop = m.stop("BEATTY_AIRPORT")
    assert_equal 3, stop.available_hops.length
    assert_equal 3, stop.available_hops_after(Time.parse("7:59:00")).length
    
    assert_equal 3, stop.available_hops_after(Time.parse("8:00:00")).length
    assert_equal 1, stop.available_hops_after(Time.parse("8:01:00")).length
    
    assert_equal 1, stop.available_hops_after(Time.parse("13:00:00")).length
    assert_equal 0, stop.available_hops_after(Time.parse("13:01:00")).length
    
  end  
end

class HopTest < Test::Unit::TestCase
  def test_initialize
    m = MapperFactory.new('sample-feed').mapper(Date.new(2008, 11, 16)) # Sunday
    beatty     = m.stop("BEATTY_AIRPORT")
    stagecoach = m.stop("STAGECOACH")
    
    # Making our own stop_times so we can ensure arrival and departure times are sane
    from = StopTime.new :stop_sequence => 1, :arrival_time => "6:00:00", :departure_time => "6:01:00",
                        :stop_id => stagecoach.stop_id, :trip_id => "STBA", :stop => stagecoach
    to   = StopTime.new :stop_sequence => 2, :arrival_time => "6:20:00", :departure_time => "6:21:00",
                        :stop_id => beatty.stop_id, :trip_id => "STBA", :stop => beatty
    hop = Hop.new(from,to)
    assert_equal "6:01:00",        hop.departure_time
    assert_equal "6:20:00",        hop.arrival_time
    assert_equal "STBA",           hop.trip_id
    assert_equal beatty,           hop.destination
  end
end

class CalendarTest < Test::Unit::TestCase
  def setup
    @calendars = Calendar.load("sample-feed/calendar.txt")
    @fullw = @calendars.detect {|c| c.service_id == "FULLW"}
    @we = @calendars.detect {|c| c.service_id == "WE"}
  end
  
  def test_fullw_has_service_on_all_days
    assert @fullw.has_service_on?(:monday)
    assert @fullw.has_service_on?(:tuesday)
    assert @fullw.has_service_on?(:wednesday)
    assert @fullw.has_service_on?(:thursday)
    assert @fullw.has_service_on?(:friday)
    assert @fullw.has_service_on?(:saturday)
    assert @fullw.has_service_on?(:sunday)
  end

  def test_we_has_no_service_on_weekdays
    assert_equal false, @we.has_service_on?(:monday)
    assert_equal false, @we.has_service_on?(:tuesday)
    assert_equal false, @we.has_service_on?(:wednesday)
    assert_equal false, @we.has_service_on?(:thursday)
    assert_equal false, @we.has_service_on?(:friday)
  end

  def test_we_has_service_on_weekends
    assert @we.has_service_on?(:saturday)
    assert @we.has_service_on?(:sunday)
  end
end
