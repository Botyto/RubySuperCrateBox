require_relative "resourceManager.rb"
require_relative "sceneManager.rb"
require_relative "common.rb"

class GameObject
  attr_accessor :velocity, :gravity, :angle, :frame, :solid, :animation_speed, :tint
  attr_reader :active, :sprite, :position_previous,  :position, :sprite_scale

  def initialize
    @position_previous = @position = Point.new
    @velocity = Point.new
    @sprite_scale = Point::one
    @gravity = 0
    @friction = 0

    @angle = 0
    @frame = 0
    @animation_speed = 1
    @tint = Color::WHITE
    set_sprite nil
    
    @platformer = false

    @active = true
  end

  def update
    # update sprite
    @frame += @animation_speed
    
    # update movement & position
    if speed > @friction then
      @velocity.length -= @friction
    else
      @velocity = Point.zero
    end
    @velocity.y += @gravity
    @position_previous = @position

    @velocity.y = 6*@velocity.y.sign if @velocity.y.abs > 6

    # platformer logic
    if @platformer then
      @gravity = GRAVITY if SceneManager::solid_free? aabb + Point.unit_y

      # apply vertical movement
      @velocity.y.abs.ceil.times do |i|
        if !SceneManager::solid_free? aabb + Point.new(@velocity.y.sign, 0) then
          # move outside solid
          while !SceneManager::solid_free? aabb do
            @position.y -= @velocity.y.sign
          end

          @velocity.y = 0
          @gravity = 0
          break
        else
          @position.y += @velocity.y.sign
        end
      end

      # apply horizontal movement
      @velocity.x.abs.ceil.times do |i|
        @position.x += @velocity.x.sign if SceneManager::solid_free? aabb + Point.new(@velocity.x.sign, 0)
      end
    else
      @position += @velocity
    end

    # handle collisions with other objects
    handle_collisions
  end

  def aabb(offset = nil)
    return @sprite.aabb(position + (offset ? offset : Point.new)) if @sprite
    Rectangle.new
  end

  def base_aabb(position = nil)
    return @sprite.aabb(position ? position : Point.new) if @sprite
    Rectangle.new
  end

  def handle_collisions
    SceneManager.objects.each do |other|
      if @sprite and other.sprite then
        collide other if aabb.intersects? other.aabb
      elsif @sprite and !other.sprite then
        collide other if aabb.point_inside? other.position
      elsif !@sprite and other.sprite then
        collide other if other.aabb.point_inside? @position
      else
        collide other if @position == other.position
      end
    end
  end

  def collide(other)
  end

  def draw
    # draw self, if a sprite is set
    if @sprite != nil then
      sprite.draw_rot_frame(frame, @position.x, @position.y, @sprite.z, @angle, @sprite_scale.x, @sprite_scale.y, @tint)
    end
  end

  def set_sprite(sprite)
    # if a string is provided, then use it to find the sprite in the resources
    if sprite.is_a? String then
      @sprite = ResourceManager.sprites[sprite]
    else
      @sprite = sprite
    end
  end

  def position=(position)
    # only set the position if a Point is provided
    if position.is_a? Point then
      @position = position
    end
  end

  def speed=(new_speed)
    @velocity.length = new_speed
  end

  alias :set_speed :speed=

  def destroy
    @active = false
  end

  def button_pressed(button)
  end

  def button_released(button)
  end

  def speed
    @velocity.length
  end

  def speed=(new_speed)
    if speed == 0 then
      @velocity = Point::unit_x*new_speed
    else
      @velocity *= new_speed/speed
    end
  end

  def direction
    @velocity.angle
  end

  def direction=(degrees)
    @velocity.angle = degrees
  end

  def inside_scene?
    SceneManager.point_inside? position
  end
end
