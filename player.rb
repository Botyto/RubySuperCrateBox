require_relative "gameObject.rb"
require_relative "resourceManager.rb"
require_relative "sceneManager.rb"
require_relative "common.rb"
require_relative "weapons.rb"

class Player < GameObject
  attr_reader :alive, :weapon, :level, :shooting

  class << self
    def initialize
      @@crates_collected = 0
    end

    def initialize_weapons
      @@weapons = Hash.new
      filenames = Weapon.all_weapons
      filenames.each { |file| parse_weapon file }
    end

    def weapon(name)
      @@weapons[name.to_s]
    end

    def weapon_random(level = 9999)
      @@weapons.keep_if { |name, wep| wep.level <= level }.to_a.sample[1]
    end

    def parse_weapon(filename)
      full_filename = DATA_WEP + filename + EXT_WEAPON
      return if !File.exist? full_filename
      @@weapons[filename] = parse_class(full_filename, Weapon)
    end

    def player
      @@player
    end

    def crates_collected
      @@crates_collected
    end
  end

  def initialize
    super

    @@player = self
    @@crates_collected = 0

    set_sprite "player"
    @gravity = GRAVITY
    @animation_speed = 0.2

    @alive = true
    @level = 5

    @shooting = false
    @weapon = Player::weapon(:pistol)

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
      other.replace!
      @weapon = Player.weapon_random
      @@crates_collected += 1
      FloatingText.create @position, @weapon.name, 10
      ResourceManager.sounds["crate_collected"].play
    end
  end

  def kill
    return if !@alive

    ResourceManager.sounds["player_die"].play

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
        if !SceneManager::solid_free? aabb + Point.unit_y then
          @velocity.y = -@jump_speed
          ResourceManager.sounds["player_jump"].play
        end
      end
    end
  end

  def button_released(key)
    if key == KbX then
      @shooting = false
      @weapon.shoot_released if @weapon
    end
  end

  def destroy
    GameWindow.end_game @@crates_collected
  end
end

class Crate < GameObject
  def initialize
    super
    set_sprite "crate"
    replace!
  end

  def replace!
    @position = Point::random(GameWindow.width, GameWindow.height)
    while !SceneManager::solid_free? aabb do
      @position = Point.random(GameWindow.width, GameWindow.height)
    end
    @gravity = GRAVITY
  end

  def update
    return if @gravity <= 0
    replace! if @position.y > GameWindow.height

    @velocity.y += @gravity

    @velocity.y.ceil.times do |i|
      if SceneManager::solid_free? aabb + Point.unit_y then
        @position.y += 1
      else
        @velocity.y = 0
        @gravity = 0
        break
      end
    end
  end
end

class FloatingText < GameObject
  attr_accessor :text, :size, :color, :has_shadow

  def initialize
    super
    @gravity = -0.05
    @text = "---"
    @size = 5
    @color = Color::WHITE
    @has_shadow = true
  end

  def update
    super
    destroy if @position.y < 0
  end

  def draw
    ResourceManager.fonts["pixel"].draw(@size, @text, @position.x, @position.y, 100, 1, 1, @color)
    return if !@has_shadow
    ResourceManager.fonts["pixel"].draw(@size, @text, @position.x + 2, @position.y + 2, 99, 1, 1, Color::BLACK)
  end

  def self.create(position, text = "---", height = 5)
    obj = SceneManager.add_object FloatingText, position
    obj.text = text
    obj.size = height
    obj
  end

  def method_missing(method, *arguments, &block)
  end
end
