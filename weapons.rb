require_relative "gameObject.rb"

class Weapon
  attr_accessor :name, :sprite, :sound, :shot_object, :level, :can_hold, :interval, :shots,
        :push, :shake, :spread, :shot_speed, :shot_speed_offset
  attr_reader :timer

  def self.all_weapons
    ["pistol", "machinegun", "shotgun", "revolver", "katana", "bazooka", "mines", "flamethrower",
     "disc_gun", "grenade_launcher", "dual_pistol", "chainsaw", "minigun", "laser", "napalm"]
  end

  def initialize
    @timer = 0
    @can_shoot = true
  end

  def draw(position)
    return if !@sprite
    @sprite.draw(position.x, position.y, @sprite.z)
  end

  def update
    @timer -= 1 if @timer > 0
  end

  def shoot(shooter, position, direction)
    return if !@shot_object

    @timer = @interval
    ResourceManager.sounds[@sound].play if ResourceManager.sounds[@sound]
    GameWindow.game.shake @shake


    @shots.times do
      shot = SceneManager.add_object @shot_object, position

      if @shot_speed and @shot_speed > 0 then
        shot.velocity = Point.angle_len(rand(-@spread..@spread),
                                        @shot_speed + rand(@shot_speed_offset))
        shot.velocity.x *= direction
      end
    end

    shooter.position += Point.new(-direction*@push, 0)
  end

  def is_allowed?(level)
    level >= @level
  end

  def can_shoot?(level)
    return false if @timer > 0
    return false if !is_allowed? level
    return false if !@can_shoot

    return true
  end

  def shoot_pressed(shooter)
    return if !can_shoot? shooter.level
    @can_shoot = false if !@can_hold
    shoot shooter, shooter.position, shooter.sprite_scale.x
  end

  def shoot_released
    @can_shoot = true
  end
end

class Bullet < GameObject
  def initialize
    super
    set_sprite "bullet"
  end

  def update
    super
    destroy if !inside_scene? or !SceneManager.solid_free? aabb
  end

  def collide(other)
    case other
    when Enemy
      other.damage 2
      destroy
    end
  end
end

class ShotgunBullet < Bullet
  def initialize
    super
    @friction = 0.5
  end

  def update
    super

    destroy if speed <= 0
  end
end

class Explosion < GameObject
  def initialize
    super
    set_sprite "explosion"
    @animation_speed = 0.1
    @sprite_scale = Point.new(0.5, 0.5)
    GameWindow.game.shake 5
    ResourceManager.sounds["explosion"].play if ResourceManager.sounds["explosion"]
  end

  def update
    super
    @sprite_scale += 0.1
    destroy if @frame > @sprite.num_frames
  end

  def collide(other)
    return if !other.is_a? Enemy
    other.damage 8
  end
end

class Mine < GameObject
  def initialize
    super
    set_sprite "mine"
    @platformer = true
  end

  def collide(other)
    case other
    when Enemy
      destroy
    end
  end

  def destroy
    super
    SceneManager.add_object Explosion, @position
  end
end
