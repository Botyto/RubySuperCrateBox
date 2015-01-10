require_relative "common.rb"

class SceneManager
  class << self
    attr_reader :objects
    attr_accessor :current_level, :background_color

    def initialize
      @objects = Array.new
      @current_level = nil
      @background_color = Color.new(255, 180, 212, 238)
    end

    def add_object(object)
      if object.is_a? Class then
        @objects.push object.new
        debug_log "Add #{object}"
      else
        @objects.push object
        debug_log "Add #{object.class}"
      end
    end

    def add_object(klass, position)
      object = klass.new
      object.set_position position
      @objects.push object
      debug_log "Add #{object.class}"
    end

    def update
      @objects.each { |object| object.update }

      size = @objects.size
      @objects = @objects.keep_if { |object| object.active }
      debug_log "Remove #{size - @objects.size} objects" if size != @objects.size
    end

    def draw
      @objects.each { |object| object.draw }
      if @current_level then @current_level.draw end
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
  
    def activate_level(level)
      @current_level = level
      level.activate
    end
  end
end
