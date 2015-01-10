require_relative "gameObject.rb"

class Enemy < GameObject
  def initialize
    super
  end
end

class Spawner < GameObject
  def initialize
    super
  end
end

class Fire < GameObject
  def initialize
    super
    set_sprite "fire"
    @animation_speed = 0.2
  end
end