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

    def parse_weapon(filename)
      full_filename = DATA_WEP + filename + EXT_WEAPON
      return if !File.exist? full_filename
      @@weapons[filename] = parse_class(full_filename, Weapon)
    end
  end

  def initialize
    super
    set_sprite "player"
    @animation_speed = 0.2
    @alive = true
    @level = 5
    @shooting = false
    @weapon = @@weapons["shotgun"]
  end

  def update
    super

    if @alive then
      @weapon.shoot_pressed self if @shooting
      @weapon.update if @weapon
    else
      @angle += 10
      destroy if @position.y > GameWindow.height
    end
  end

  def collide(other)
    case other
    when Crate
      other.destroy
      
    end
  end

  def kill
    @alive = false
    @gravity = GRAVITY

    set_sprite "player"
    @animation_speed = 0
    @frame = 0
    @angle = 0
  end

  def button_pressed(key)
    if key == KbX and @weapon then
      @shooting = true
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
  end
end