require_relative "resourceManager.rb"
require_relative "sceneManager.rb"
require_relative "common.rb"

class GameObject
  attr_accessor :velocity, :gravity, :angle, :frame, :solid,
      :animation_speed
  attr_reader :active, :sprite, :position_previous, :position

  def initialize
    @position_previous = @position = Point.new
    @velocity = Point.new
    @gravity = 0
    @friction = 0

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
    if speed > @friction then
      @velocity.length -= @friction
    else
      @velocity = Point.zero
    end
    @velocity.y += @gravity
    @position_previous = @position
    @position += @velocity

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
      sprite.draw_rot_frame(frame, @position.x, @position.y, @sprite.z, @angle)
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

  def set_speed(new_speed)
    @velocity.length = new_speed
  end

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

  def move_collide_solid(position, destination)
    position == (position = try_collide_diagonal(position, destination))
  end

  def try_collide_diagonal(position, destination)
    movement = MovementWrapper.new(position, destination, self)

    movement.steps_count.times do |i|
      position_to_try = position + movement.step*i

      if SceneManager.solid_free? movement.bounds(position_to_try) then
        movement.furthest = try_collide_non_diagonal(movement, i)
        break
      end

      movement.furthest = position_to_try
    end

    return movement.furthest
  end

  def try_collide_non_diagonal(movement, i)
    return movement.furthest if !movement.is_diagonal?

    steps_left = movement.steps_count - (i - 1)
    remaining_move = movement.step * steps_left

    movement.furthest = try_collide_diagonal(movement.furthest, movement.furthest + remaining_move*Point::unit_x)
    movement.furthest = try_collide_diagonal(movement.furthest, movement.furthest + remaining_move*Point::unit_y)

    return movement.furthest
  end
end
