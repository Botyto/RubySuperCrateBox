require_relative "common.rb"
require_relative "player.rb"
require_relative "enemies.rb"

class Level
  attr_reader :player, :spawn_points, :fires, :walls, :width, :height

  def initialize(width, height)
    @player = Point.new
    @spawn_points = Array.new
    @fires = Array.new
    @walls = Array.new
    set_size(width, height)
  end
  
  def set_player(x, y)
    @player = Point.new((x + 1)*GRID_WIDTH, (y + 0.5)*GRID_HEIGHT)
  end
  
  def add_spawn(x, y)
    @spawn_points.push Point.new((x + 1)*GRID_WIDTH, (y + 0.5)*GRID_HEIGHT)
  end
  
  def add_fire(x, y)
    @fires.push Point.new((x + 0.5)*GRID_WIDTH, (y + 0.5)*GRID_HEIGHT)
  end
  
  def set_size(width, height)
    @width = width
    @height = height
    
    for row in 0..width
      @walls[row] = Array.new
      for column in 0..height
        @walls[row][column] = false
      end
    end
  end
  
  def set_blocked(x, y, blocked = true)
    if x < 0 or x >= width or y < 0 or y >= height then return end
    @walls[x][y] = blocked
  end
  
  def blocked?(x, y)
    if x < 0 or y < 0 or x >= width or y >= height then return false end
    @walls[x][y]
  end
  
  def start
    SceneManager.add_object(Player, @player)
    @spawn_points.each { |spawn| SceneManager.add_object(Spawner, spawn) }
    @fires.each { |fire| SceneManager.add_object(Fire, fire) }
  end
  
  def draw
    @walls.each_index do |x|
      @walls[x].each_index do |y|
        if blocked?(x, y) then
          ResourceManager.sprites["wall"].draw(x*GRID_WIDTH, y*GRID_HEIGHT, 0)
        end
      end
    end
  end
end
