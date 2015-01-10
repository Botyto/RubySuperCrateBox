require_relative "gameObject.rb"
require_relative "resourceManager.rb"
require_relative "sceneManager.rb"
require_relative "common.rb"

class Player < GameObject
  attr_reader :alive
  
  def initialize
    super
    set_sprite "player"
    @animation_speed = 0.2
    @alive = true
  end

  def update
    super

    if !@alive then
      @angle += 10
      destroy if @position.y > SceneManager.current_level.height*10
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
end