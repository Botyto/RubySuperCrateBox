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
    raise ArgumentError, "Provided X isn't Numeric" unless x.is_a? Numeric
    raise ArgumentError, "Provided Y isn't Numeric" unless y.is_a? Numeric
    raise ArgumentError, "Provided point isn't Point" unless point.is_a? Point

    assert_in_delta(x, point.x, delta, "#{message} (X is different)")
    assert_in_delta(y, point.y, delta, "#{message} (Y is different)")
  end

  def assert_point_angle(angle, point, message = nil, delta = 0.001)
    raise ArgumentError, "Provided angle isn't Numeric" unless angle.is_a? Numeric
    raise ArgumentError, "Provided point isn't Point" unless point.is_a? Point

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
    assert_in_delta(1, @one.normalize.length)

    assert_point(1, 0, @unit_x.normalize)
    assert_in_delta(1, @unit_x.normalize.length)

    @pythagoras.normalize!

    assert_in_delta(1, @pythagoras.length)
  end

  def test_point_length_angle_and_distances
    sqrt2 = Math.sqrt(2)
    pythagoras_angle = rad_to_deg(Math.atan2(4, 3))

    assert_in_delta(sqrt2, @one.length)
    assert_in_delta(5, @pythagoras.length)

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

class TestRectangle < Test
  def assert_rectangle(x, y, w, h, rectangle, message = nil, delta = 0.001)
    raise ArgumentError, "Provided X isn't Numeric" unless x.is_a? Numeric
    raise ArgumentError, "Provided Y isn't Numeric" unless y.is_a? Numeric
    raise ArgumentError, "Provided W isn't Numeric" unless w.is_a? Numeric
    raise ArgumentError, "Provided H isn't Numeric" unless h.is_a? Numeric
    raise ArgumentError, "Provided rectangle isn't Rectangle" unless rectangle.is_a? Rectangle

    assert_in_delta(x, rectangle.x, delta, "#{message} (X is different)")
    assert_in_delta(y, rectangle.y, delta, "#{message} (Y is different)")
    assert_in_delta(w, rectangle.w, delta, "#{message} (W is different)")
    assert_in_delta(h, rectangle.h, delta, "#{message} (H is different)")
  end

  def test_rectangle_generation
    assert_rectangle(0, 0, 0, 0, Rectangle.new)
    assert_rectangle(1, 2, 3, 4, Rectangle.new(1, 2, 3, 4))
  end

  def test_rectangle_intersection
    rect1 = Rectangle.new(0, 0, 1, 1)
    rect2 = Rectangle.new(0.25, 0.25, 0.5, 0.5)
    rect3 = Rectangle.new(2, 2, 1, 1)
    rect4 = Rectangle.new(2, 1, 1, 1)

    assert(rect1.intersects? rect2)
    assert(rect3.intersects? rect4)
    refute(rect1.intersects? rect3)
  end

  def test_rectangle_point_inside
    rect = Rectangle.new(0, 0, 1, 1)
    point1 = Point.new(0, 0)
    point2 = Point.new(0.5, 0.5)
    point3 = Point.new(3, 3)

    assert(rect.point_inside? point1)
    assert(rect.point_inside? point2)
    refute(rect.point_inside? point3)
  end

  def test_rectangle_arithmetics
    rect = Rectangle.new(1, 1, 1, 1)
    point = Point.new(2, 2)

    assert_rectangle( 3,  3, 1, 1, rect + point)
    assert_rectangle(-1, -1, 1, 1, rect - point)
  end

  def test_rectangle_others
    rect = Rectangle.new(1, 1, 1, 1)

    assert_in_delta(2, rect.x2)
    assert_in_delta(2, rect.y2)
    assert_in_delta(1, rect.area)
  end
end
