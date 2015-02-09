require_relative "gameObject.rb"
require_relative "sceneManager.rb"
require_relative "player.rb"
require_relative "common.rb"

class Enemy < GameObject
  def initialize
    super
    set_sprite "enemy"
    @velocity.y = 1
    @velocity.x = [1, -1].sample
    @gravity = GRAVITY
    @animation_speed = 0.25
    @health = 4
  end

  def update
    if !SceneManager::solid_free? aabb then
      if move_collide_solid(@position_previous, @position) then
        @gravity = 0
        @velocity.y = 0
        while !SceneManager::solid_free? aabb do
          @position.y -= 1
        end
      else
        @gravity = GRAVITY
      end
    else
      @gravity = GRAVITY
    end

    if !SceneManager::solid_free?(aabb + Point.new(@velocity.x.sign*2, 0)) then
      @velocity.x *= -1
    end

    super

    destroy if @position.y > GameWindow.height
  end

  def collide(other)
    case other
      when Player
        other.kill if other.alive
    end
  end

  def draw
    if @sprite != nil then
      sprite.draw_rot_frame(frame, @position.x, @position.y, @sprite.z, @angle, @velocity.x.sign)
    end
  end

  def destroy
    super
  end
end

class Spawner < GameObject
  def spawn_interval
    if SceneManager.current_scene then
      SceneManager.current_scene.spawn_interval
    else
      60*2
    end
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