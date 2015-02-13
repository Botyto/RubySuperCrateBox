require "minitest/autorun"
include MiniTest

require_relative "../common.rb"

class TestPoint < Test
  def setup
    @zero = Point.zero
    @one = Point.one
    @unit_x = Point.unit_x
    @unit_y = Point.unit_y

    @point1 = Point.new(15, 10)
    @point2 = Point.new(3, 2)
    @point3 = Point.new(5.5, 4.3)
    @pythagoras = Point.new(3, 4)

    @random1 = Point.random(1, 1)
    @random2 = Point.random(1, 1)
  end

  def assert_point(x, y, point, message = nil, delta = 0.001)
    assert_kind_of(Numeric, x, "Provided X isn't Numeric")
    assert_kind_of(Numeric, y, "Provided Y isn't Numeric")
    assert_kind_of(Point, point, "Provided point isn't a Point")

    assert_in_delta(x, point.x, delta, "#{message} (X is different)")
    assert_in_delta(y, point.y, delta, "#{message} (Y is different)")
  end

  def assert_point_length(length, point, message = nil, delta = 0.001)
    assert_kind_of(Numeric, length, "Provided length isn't Numeric")
    assert_kind_of(Point, point, "Provided point isn't a Point")

    assert_in_delta(length*length, point.length_squared, delta, message)
  end

  def assert_point_angle(angle, point, message = nil, delta = 0.001)
    assert_kind_of(Numeric, angle, "Provided angle isn't Numeric")
    assert_kind_of(Point, point, "Provided point isn't a Point")

    assert_in_delta(angle, rad_to_deg(point.angle), delta, message)
  end

  def test_point_generation
    assert_point(15, 10, @point1)
    refute_equal(@random1, @random2)
  end

  def test_point_standart_points
    assert_point(0, 0, @zero)
    assert_point(1, 1, @one)
    assert_point(1, 0, @unit_x)
    assert_point(0, 1, @unit_y)
  end

  def test_point_arithmetics
    assert_point(15 + 3, 10 + 3, @point1 + 3)
    assert_point(15 - 3, 10 - 3, @point1 - 3)
    assert_point(15 * 5, 10 * 5, @point1 * 5)
    assert_point(15 / 5, 10 / 5, @point1 / 5)

    assert_point(15 + 3, 10 + 2, @point1 + @point2)
    assert_point(15 - 3, 10 - 2, @point1 - @point2)
    assert_point(15 * 3, 10 * 2, @point1 * @point2)
    assert_point(15 / 3, 10 / 2, @point1 / @point2)
  end

  def test_point_normalize
    half_sqrt2 = 1/Math.sqrt(2)

    assert_point(half_sqrt2, half_sqrt2, @one.normalize)
    assert_point_length(1, @one.normalize)

    assert_point(1, 0, @unit_x.normalize)
    assert_point_length(1, @unit_x.normalize)

    @pythagoras.normalize!

    assert_point_length(1, @pythagoras)
  end

  def test_point_length_angle_and_distances
    sqrt2 = Math.sqrt(2)
    pythagoras_angle = rad_to_deg(Math.atan2(4, 3))

    assert_point_length(sqrt2, @one)
    assert_point_length(5, @pythagoras)

    assert_point_angle(00, @unit_x)
    assert_point_angle(45, @one)
    assert_point_angle(90, @unit_y)
    assert_point_angle(pythagoras_angle, @pythagoras)
  end

  def test_point_snap_to_grid
    assert_point(6, 4, @point3.snap_to_grid(1, 1))
    @point3.snap_to_grid!(1, 1)
    assert_point(6, 4, @point3)
  end
end
