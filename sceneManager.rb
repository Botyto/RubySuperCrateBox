require_relative "resourceManager.rb"
require_relative "common.rb"

class Scene
  attr_accessor :type, :file, :background, :music, :spawn_interval, :level, :menu_items
  attr_reader :background_sprite

  def initialize
    @level = nil
    @menu_items = nil
    @background_sprite = nil
    @background_music = nil
  end

  def parse
    parse_level
    parse_menu
    @background_sprite = ResourceManager.sprites[@background]
    @background_music = ResourceManager.sounds[@music]
  end

  def parse_level
    return if @type != TYPE_LEVEL

    lines = File.readlines(DATA + @file).map &:chomp
    @level = Level.new(lines.first.size, lines.size)
    for x in 0...@level.width
      for y in 0...@level.height
        case lines[y][x]
          when "#"
            @level.set_blocked(x, y)
          when "S"
            @level.add_spawn(x, y)
          when "P"
            @level.set_player(x, y)
          when "F"
            @level.add_fire(x, y)
        end
      end
    end
    debug_log "Parse level \"#{@file}\""
  end

  def parse_menu
    return if @type != TYPE_MENU

    debug_log "Parse menu \"#{@file}\" NOT IMPLEMENTED"
  end

  def draw
    return if !@background_sprite
    @background_sprite.draw(0, 0, 1)
  end

  def start
    @background_music.play if @background_music != nil

    if @type == TYPE_LEVEL && @level then
      @level.start
    elsif @type == TYPE_MENU && @menu_items then
      debug_log "Start menu scene NOT IMPLEMENTED"
    end
  end

  def end
    @background_music.stop if @background_music != nil
  end

  def solid_free?(aabb)
    return true if @type == TYPE_MENU

    left, right, top, bottom = map_aabb_to_grid aabb

    (left..right).each do |x|
      (top..bottom).each do |y|
        if @level.blocked? x, y then
          return false
        end
      end
    end

    return true
  end

  def map_aabb_to_grid(aabb)
    left   = (aabb.left/GRID_WIDTH).floor
    right  = (aabb.right/GRID_WIDTH).floor
    top    = (aabb.top/GRID_HEIGHT).floor
    bottom = (aabb.bottom/GRID_HEIGHT).floor

    if level then
      left   = clamp(0, left,   level.width)
      right  = clamp(0, right,  level.width)
      top    = clamp(0, top,    level.height)
      bottom = clamp(0, bottom, level.height)
    end

    return left, right, top, bottom
  end
end

class SceneManager
  class << self
    attr_reader :objects
    attr_accessor :current_scene, :background_color

    def initialize
      @objects = Array.new
      @current_scene = nil
      @background_color = Color.new(255, 180, 212, 238)
    end

    def add_object(object)
      obj = object.is_a? Class ? object.new : object
      @objects.push obj
      debug_log("Add \"#{object.class}\"", CYAN)
      obj
    end

    def add_object(klass, position)
      object = klass.new
      object.position = position
      @objects.push object
      debug_log("Add \"#{object.class}\"", CYAN)
      object
    end

    def update
      @objects.each { |object| object.update }

      size = @objects.size
      @objects = @objects.keep_if { |object| object.active }
      debug_log("Remove #{size - @objects.size} object(s)", RED) if size != @objects.size
    end

    def draw
      @current_scene.draw
      @objects.each { |object| object.draw }
    end

    def button_pressed(button)
      @objects.each { |object| object.button_pressed(button) }
    end

    def button_released(button)
      @objects.each { |object| object.button_released(button) }
    end

    def clear
      @objects.clear
    end
  
    def point_inside?(point)
      GameWindow.point_inside? point
    end

    def start_scene(scene)
      debug_log("Changing scene", MAGENTA)
      @current_scene.end if @current_scene
      clear
      @current_scene = scene
      @current_scene.start
    end

    def solid_free?(aabb)
      @current_scene ? @current_scene.solid_free?(aabb) : true
    end
  end
end
