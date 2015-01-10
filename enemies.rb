require_relative "gameObject.rb"
require_relative "sceneManager.rb"
require_relative "player.rb"
require_relative "common.rb"

class Enemy < GameObject
  def initialize
    super
    set_sprite "enemy"
    @gravity = GRAVITY
  end

  def update
    super

    destroy if @position.y > SceneManager.current_level.height*10
  end

  def collide(other)
    case other
      when Player
        other.kill if other.alive
    end
  end
end

class Spawner < GameObject
  def spawn_interval
    60 * 2
  end

  def initialize
    super
    @timer = spawn_interval
  end

  def update
    super

    @timer -= 1
    if @timer <= 0 then
      @timer = spawn_interval
      SceneManager.add_object Enemy, @position
    end
  end
end

class Fire < GameObject
  def initialize
    super
    set_sprite "fire"
    @animation_speed = 0.2
  end
end