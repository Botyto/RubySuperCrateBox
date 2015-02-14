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

  def draw(position, scale_x = 1)
    res = ResourceManager.sprites[@sprite]
    return if !res
    res.draw_rot_frame(0, position.x + scale_x*3, position.y + 2, res.z, 0, scale_x, 1)
  end

  def update
    @timer -= 1 if @timer > 0
  end

  def drop(position)
    obj = SceneManager.add_object WeaponDrop
    obj.set_sprite @sprite
    obj.position = position
    obj.velocity = Point.new rand(-2..2), -2
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

    if SceneManager.solid_free? shooter.aabb + Point.new(-direction*@push, 0)
      shooter.position += Point.new(-direction*@push, 0)
    end
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

class WeaponDrop < GameObject
  def initialize
    super
    @gravity = GRAVITY
  end

  def update
    super
    @angle += 3
    destroy if @position.y > GameWindow.height
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
    @animation_speed = 0
    @timer = 40
  end

  def update
    super
    return if @timer <= 0
    @timer -= 1
    @animation_speed = 0.2 if @timer <= 0
  end

  def collide(other)
    case other
    when Enemy
      destroy if @animation_speed > 0 and other.alive
    end
  end

  def destroy
    super
    SceneManager.add_object Explosion, @position
  end
end
