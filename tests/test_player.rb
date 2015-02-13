require "minitest/autorun"
include MiniTest

require_relative "test_tools.rb"
require_relative "../common.rb"
require_relative "../player.rb"


class SceneManager
  def self.initialize
    @@counter = {}
    @@objects = []
  end

  def self.objects
    @@objects
  end

  def self.add_object(klass, position = nil)
    klass = klass.class unless klass.is_a? Class
    key = klass.inspect
    @@counter[key] = 0 unless @@counter.has_key? key
    @@counter[key] += 1

    obj = klass.new
    @@objects.push obj
    obj
  end

  def self.cleanup_counter
    @@counter = {}
  end

  def self.cleanup_objects
    @@objects = []
  end

  def self.cleanup
    SceneManager.cleanup_counter
    SceneManager.cleanup_objects
  end

  def self.count(klass)
    key = klass.inspect
    @@counter.has_key?(key) ? @@counter[klass.inspect] : 0
  end

  def self.solid_free?(aabb)
    aabb.y1 > GameWindow.height/2
  end
end

class ResourceManager
  def self.sprites
    {}
  end
end

class SmokePuffs
  def self.create_puffs(*args)
  end
end

class GameObject
  def set_sprite(sprite)
    @sprite = nil
  end

  def size
    [0, 0]
  end

  def aabb
    Rectangle.new(@position.x - size[0]/2, @position.y - size[1]/2, size[0], size[1])
  end
end

class Crate < GameObject
  def replace!
    @position = Point::random(GameWindow.width, GameWindow.height)
    while !SceneManager::solid_free? aabb do
      @position = Point.random(GameWindow.width, GameWindow.height)
    end
  end

  def size
    [8, 8]
  end
end

class Player < GameObject
  def initialize
    @@weapons = {}
    @@crates_collected = 0
  end

  def size
    [10, 10]
  end
end


class TestPlayer < Test
  include TestTools

  def setup
    SceneManager.cleanup
  end

  def test_crate_positioning
    crates_to_test = 20
    crates_to_test.times do
      o = Crate.new
      assert(SceneManager.solid_free? o.aabb)
    end
  end

  def test_smoke_puffs_count
    puff = 2
    puff.times { SmokePuff.create_puffs Point.new }

    assert_equal(puff*5, SceneManager.count(SmokePuff))
  end

  def test_floating_text_content
    text = "Pure bullshit"
    o = FloatingText.create Point.new, text
    assert_equal(text, o.text)
  end

  def test_player_collects_crates
    crate = SceneManager.add_object Crate
    player = SceneManager.add_object Player

    player.position = Point.new
    crate.position = Point.new

    assert_equal(0, Player.crates_collected)
    player.collide crate if player.aabb.intersects? crate.aab
    assert_equal(1, Player.crates_collected)
  end
end
