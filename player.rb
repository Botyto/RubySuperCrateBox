require_relative "gameObject.rb"
require_relative "resourceManager.rb"
require_relative "sceneManager.rb"
require_relative "common.rb"
require_relative "weapons.rb"

class Player < GameObject
  attr_reader :alive, :weapon, :level, :shooting

  class << self
    def initialize_weapons
      @@weapons = Hash.new
      filenames = Weapon.all_weapons
      filenames.each { |file| parse_weapon file }
    end

    def weapon(name)
      @@weapons[name.to_s]
    end

    def parse_weapon(filename)
      full_filename = DATA_WEP + filename + EXT_WEAPON
      return if !File.exist? full_filename
      @@weapons[filename] = parse_class(full_filename, Weapon)
    end
  end

  def initialize
    super
    set_sprite "player"
    @gravity = GRAVITY
    @animation_speed = 0.2

    @alive = true
    @level = 5

    @shooting = false
    @weapon = Player::weapon(:shotgun)

    @platformer = true
    @walk_speed = 2
    @jump_speed = 5
  end

  def update
    @velocity.x = 0
    if @alive then
      @velocity.x = -@walk_speed if GameWindow.button_down?(KbLeft)
      @velocity.x = @walk_speed if GameWindow.button_down?(KbRight)
      @sprite_scale.x = @velocity.x.sign if @velocity.x != 0
    end

    if !SceneManager::solid_free?(aabb + Point.new(@velocity.x, 0)) then
      @position.x -= @velocity.x.sign
      @velocity.x = 0
    end

    super

    if @alive then
      @weapon.shoot_pressed self if @shooting
      @weapon.update if @weapon
    else
      @angle += 10
      destroy if @position.y > GameWindow.height
    end

    kill if @position.y > GameWindow.height
  end

  def collide(other)
    case other
    when Crate
      other.destroy
    end
  end

  def kill
    return if !@alive

    @alive = false
    @gravity = GRAVITY
    @platformer = false

    set_sprite "player"
    @animation_speed = 0
    @frame = 0
    @angle = 0
  end

  def button_pressed(key)
    # alive actions
    if @alive then
      if key == KbX and @weapon then
        @shooting = true
      elsif (key == KbUp or key == KbZ) then
        @velocity.y = -@jump_speed if !SceneManager.solid_free? aabb + Point.unit_y
      end
    end
  end

  def button_released(key)
    if key == KbX then
      @shooting = false
      @weapon.shoot_released if @weapon
    end
  end
end

class Crate < GameObject
  def initialize
    super
    set_sprite "crate"
    @gravity = GRAVITY
    @platformer = true
  end
end
