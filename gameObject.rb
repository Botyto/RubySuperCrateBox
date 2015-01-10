require_relative "resourceManager.rb"
require_relative "sceneManager.rb"
require_relative "common.rb"

class GameObject
  attr_accessor :position, :velocity, :gravity, :angle, :frame, :solid,
      :animation_speed
  attr_reader :active, :sprite

  def initialize
      @position = Point.new
      @velocity = Point.new
      @gravity = 0

      @angle = 0
      @frame = 0
      @animation_speed = 1
      set_sprite nil
      
      @active = true
  end

  def update
    # update 
    @frame += @animation_speed

    # update movement & position
    @velocity.y += @gravity
    @position += @velocity

    # handle collisions with other objects
    handle_collisions
  end

  def aabb
    @sprite.aabb position
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
      sprite.draw_rot_frame(frame, @position.x, @position.y, @sprite.z, angle)
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

  def set_position(position)
    # only set the position if a Point is provided
    if position.is_a? Point then
      @position = position
    end
  end

  def destroy
    @active = false
  end

  def button_pressed(button)
  end

  def button_released(button)
  end

  def speed
    velocity.length
  end

  def speed=(new_speed)
    old_speed = speed
    @velocity.x *= new_speed / old_speed
    @velocity.y *= new_speed / old_speed
  end

  def direction
    Math.atan2(@velocity.x, @velocity.y)
  end

  def direction=(degrees)
    radians = deg_to_rad degrees
    new_x =  Math.cos(radians) * speed
    new_y = -Math.sin(radians) * speed
    @velocity.x, @velocity.y = new_x, new_y
  end

  def inside_scene?
    SceneManager.point_inside? position
  end
end
