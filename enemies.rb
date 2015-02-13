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
    @alive = true
    @angry = false

    @velocity.y = 1
    @velocity.x = @walk_speed*[1, -1].sample

    @platformer = true
    @tint_timer = 0

    @sound_die = ResourceManager.sounds["zombie_die"]
  end

  def update
    super

    if @alive then
      if !SceneManager::solid_free?(aabb + Point.new(@velocity.x, 0)) then
        @velocity.x *= -1
      end

      @sprite_scale.x = @velocity.x.sign
      get_angry if @position.y > GameWindow.height and @alive
    else
      @angle += 3
      destroy if @position.y > GameWindow.height
    end

    if @tint_timer > 0 then
      @tint_timer -= 1
      @tint = Color::WHITE if @tint_timer == 0
    end
  end

  def collide(other)
    case other
      when Player
        other.kill if @alive
    end
  end

  def damage(amount)
    return unless @alive
    @health -= amount
    @tint = Color::RED
    @tint_timer = 4

    kill if @health <= 0
  end

  def kill
    return unless @alive
    @alive = false
    @platformer = false
    @velocity.x = rand(-1..1)
    @velocity.y = -2
    @gravity = GRAVITY
    @sound_die.play
  end

  def get_angry
    return if @angry or !@alive

    @angry = true

    @walk_speed = 2
    @velocity.x = @walk_speed*@velocity.x.sign

    @position.y = 10
    @position.x = GameWindow.width/2 + 10 if !SceneManager.solid_free? aabb

    set_sprite "enemy_angry"
    ResourceManager.sounds["get_angry"].play
  end
end

class Flyer < Enemy
  def initialize
    super
    set_sprite "flyer"
    @platformer = false
    @gravity = 0.01
    @velocity.x = [1, -1].sample
    @sound_die = ResourceManager.sounds["flyer_die"]
  end

  def update
    if @health > 0 then
      @velocity.y += 0.1 if @position.y < 20
      @velocity.y += 0.01
      @velocity.x += @velocity.x.sign*0.1 if @velocity.x.abs < 0.4

      if SceneManager.solid_free? aabb then
        @velocity.x *= -1 if !SceneManager.solid_free? aabb + Point.new(@velocity.x, 0)
        @velocity.y *= -1 if !SceneManager.solid_free? aabb   + Point.new(0, @velocity.y)
      end

      @velocity.length = 0.5 if self.speed > 0.5
      @sprite_scale.x = (Player.player.position.x - @position.x).sign
    end

    super
  end

  def get_angry
    super
    set_sprite "flyer_angry"
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
      SceneManager.add_object [Enemy, Flyer].sample, @position
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
