require "minitest/autorun"
include MiniTest

require_relative "../common.rb"

WIDTH = 26 unless WIDTH
HEIGHT = 18 unless HEIGHT

GRID_WIDTH = 10 unless GRID_WIDTH
GRID_HEIGHT = 10 unless GRID_HEIGHT

GRAVITY = 0.5 unless GRAVITY

module TestTools
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
end

class GameWindow
  def self.width
    (WIDTH-2)*GRID_WIDTH
  end

  def self.height
    (HEIGHT-2)*GRID_HEIGHT
  end
end
