require "rubygems"
require "gosu"

require_relative "sceneManager.rb"
require_relative "resourceManager.rb"
require_relative "common.rb"
require_relative "player.rb"

include Gosu

WIDTH = 26
HEIGHT = 18

class GameWindow < Window
  class << self
    def game
      @@game
    end

    def bounds
      @@bounds
    end

    def point_inside?(point)
      @@bounds.point_inside? point
    end

    def clear
      print "\e[2J"
    end

    def move_home
      print "\e[H"
    end

    def flush
      $stdout.flush
    end

    def set_color(color)
      print "\033[#{color}m"
    end

    def reset_color
      print "\033[0m"
    end

    def move_cursor(x, y)
      # not implemented
    end

    def height
      @@game.height
    end

    def width
      @@game.width
    end

    def method_missing(method, *arguments, &block)
      if @@game.respond_to? method then
        return @@game.send method, *arguments, &block
      else
        debug_log "Call to a missing method '#{method}' in GameWindows", RED
      end
    end
  end

  def initialize
    super((WIDTH-2)*GRID_WIDTH, (HEIGHT-2)*GRID_HEIGHT, false)
    @caption = "Ruby Super Crate Box"
    @@bounds = Rectangle.new(GRID_WIDTH, GRID_HEIGHT, (WIDTH-2)*GRID_WIDTH, (HEIGHT-2)*GRID_HEIGHT)
    @@game = self
    
    ResourceManager.initialize self
    ResourceManager.load
    Player.initialize_weapons
    SceneManager.initialize
    SceneManager.start_scene(ResourceManager.scenes["level1"])
    
    @shake = 0
    @camera = Point.new(GRID_WIDTH, GRID_HEIGHT)
  end

  def update
    SceneManager.update
  end
  
  def shake(amount)
    @shake = amount
  end

  def stop_shaking
    @shake = 0
  end

  def draw
    #GameWindow.clear
    #GameWindow.move_home

    # shake the camera
    @offset = @camera
    if @shake and @shake > 0 then
      @offset += Point.new(rand(-@shake..@shake), -rand(@shake))
      stop_shaking
    end

    # translate the camera and draw everything
    translate(-@offset.x, -@offset.y) do
      SceneManager.draw
    end

    #GameWindow.flush
  end
  
  def button_down(button)
    close if button == KbEscape
    SceneManager.button_pressed button
  end
  
  def button_up(button)
    SceneManager.button_released button
  end

  def needs_cursor?
    true
  end
end
