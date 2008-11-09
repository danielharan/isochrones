require 'test/unit'
require 'mapper'
require 'rubygems'


class MapperTest < Test::Unit::TestCase
  
  def test_initialize
    m = Mapper.new
    assert_not_nil m.routes
    assert_equal 5, m.routes.size
    
    assert_not_nil m.trips
  end
  
end


class RouteTest < Test::Unit::TestCase
  
  def test_load
    assert_equal 5, Route.load("sample-feed/routes.txt").size
  end
end