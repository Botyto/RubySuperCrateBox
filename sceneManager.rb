require_relative "common.rb"

class Scene
  attr_accessor :type, :file, :background, :spawn_interval, :level, :menu_items

  def initialize
    @level = nil
    @menu_items = nil
  end

  def parse
    parse_level
    parse_menu
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

  def start
    if @type == TYPE_LEVEL && @level then
      @level.start
    elsif @type == TYPE_MENU && @menu_items then
      debug_log "Start menu scene NOT IMPLEMENTED"
    end
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
      debug_log "Add #{object.class}"
      obj
    end

    def add_object(klass, position)
      object = klass.new
      object.set_position position
      @objects.push object
      debug_log "Add #{object.class}"
      object
    end

    def update
      @objects.each { |object| object.update }

      size = @objects.size
      @objects = @objects.keep_if { |object| object.active }
      debug_log "Remove #{size - @objects.size} objects" if size != @objects.size
    end

    def draw
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
      clear
      scene.start
      @current_scene = scene
    end
  end
end
