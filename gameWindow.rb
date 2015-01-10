require "rubygems"
require "gosu"

require_relative "sceneManager.rb"
require_relative "resourceManager.rb"
require_relative "common.rb"

include Gosu

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
      print "\e[#{@color}m"
    end

    def reset_color
      print "\e[0m"
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
  end

  def initialize
    super(26*10, 18*10, false)
    @caption = "Ruby Super Crate Box"
    @@bounds = Rectangle.new(0, 0, 26*10, 18*10)
    @@game = self
    
    ResourceManager.initialize self
    ResourceManager.load
    SceneManager.initialize
    SceneManager.start_scene(ResourceManager.scenes["level1"])
    
    @camera = Point.new
  end

  def update
    SceneManager.update
  end
  
  def draw
    #GameWindow.clear
    #GameWindow.move_home

    if SceneManager.background_color then
      col = SceneManager.background_color
      draw_quad(0, 0, col, width, 0, col, width, height, col, 0, height, col, 0, :default) 
    end

    translate(-@camera.x, -@camera.y) do
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
