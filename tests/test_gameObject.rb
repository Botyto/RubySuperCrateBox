require "minitest/autorun"
require "gosu"
include MiniTest

require_relative "../common.rb"
require_relative "../gameObject.rb"
require_relative "../resourceManager.rb"
require_relative "../sceneManager.rb"
require_relative "test_tools.rb"


module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end


class GameObject
  attr_writer :sprite
end


class TestGameObject < Test
  include TestTools

  def setup
    @obj = GameObject.new
    @obj2 = GameObject.new

    @spr = Sprite.new
    @spr.name = "spr"
    @spr.image = nil
    @spr.tiled = false
    @spr.z = 0
    @spr.height = 10
    @spr.width = 10
    @spr.color = DEFAULT
    @spr.ascii = "S"
  end

  def test_initial_properties
    assert_kind_of(Point, @obj.velocity)
    assert_kind_of(Numeric, @obj.gravity)
    assert_kind_of(Numeric, @obj.angle)
    assert_kind_of(Integer, @obj.frame)
    assert_kind_of(Boolean, @obj.solid)
    assert_kind_of(Numeric, @obj.animation_speed)
    assert_kind_of(Gosu::Color, @obj.tint)

    assert_kind_of(Boolean, @obj.active)
    refute(@obj.sprite)
    assert_kind_of(Point, @obj.position_previous)
    assert_kind_of(Point, @obj.position)
    assert_kind_of(Point, @obj.sprite_scale)
  end

  def test_aabb
    @obj.sprite = @spr
    @obj.position += Point.new(10, 25)

    assert_rectangle(0-5, 0-5, 10, 10, @obj.base_aabb)
    assert_rectangle(10-5, 25-5, 10, 10, @obj.aabb)
  end

  def test_collision
    @obj.sprite = @spr
    @obj2.sprite = @spr

    @obj.position = Point.new(0, 0)
    @obj2.position = Point.new(5, 5)

    assert(@obj.aabb.intersects? @obj2.aabb)
  end

  def test_destruction
    assert(@obj.active)
    @obj.destroy
    refute(@obj.active)
  end
end
