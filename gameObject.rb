require_relative "common.rb"

class GameObject
  attr_accessor :position, :velocity, :gravity, :angle, :frame
  attr_reader :active, :sprite

  def initialize(position)
      @position = position
      @velocity = Point.new
      @gravity = 0
      @angle = 0
      @frame = 0
      @sprite = nil
      
      @active = true
  end

  def update
    @frame += 1
  end

  def draw
    if @sprite != nil then
      sprite.draw_frame(frame, @position.x, @position.y, @sprite.z)
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

  def direction=(new_angle)
    new_x =  Math.cos(new_angle) * speed
    new_y = -Math.sin(new_angle) * speed
    @velocity.x, @velocity.y = new_x, new_y
  end
end
