require_relative "gameObject.rb"
require_relative "sceneManager.rb"
require_relative "player.rb"
require_relative "common.rb"

class Enemy < GameObject
  attr_reader :angry

  def initialize
    super
    set_sprite "enemy"
    @gravity = GRAVITY
    @animation_speed = 0.25

    @walk_speed = 1
    @health = 4
    @angry = false

    @velocity.y = 1
    @velocity.x = @walk_speed*[1, -1].sample

    @platformer = true
    @tint_timer = 0
  end

  def update
    super

    if !SceneManager::solid_free?(aabb + Point.new(@velocity.x, 0)) then
      @velocity.x *= -1
    end

    @sprite_scale.x = @velocity.x.sign
    get_angry if @position.y > GameWindow.height

    if @tint_timer > 0 then
      @tint_timer -= 1
      @tint = Color::WHITE if @tint_timer == 0
    end
  end

  def collide(other)
    case other
      when Player
        other.kill if @health > 0
    end
  end

  def damage(amount)
    @health -= amount
    @tint = Color::RED
    @tint_timer = 4

    kill if @health <= 0
  end

  def kill
    @platformer = false
    @velocity.x = 0
    @gravity = GRAVITY
  end

  def get_angry
    return if @angry

    @angry = true
    @walk_speed = 2
    @velocity.x = @walk_speed*@velocity.x.sign
    @position.y = 0
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
