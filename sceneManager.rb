LOG = true

class SceneManager
  class << self
    attr_reader :objects
    attr_accessor :current_level

    def initialize
      @objects = Array.new
      @current_level = nil
    end

    def add_object(object)
      @objects.push object
      puts "adding #{object.class}" if LOG
    end

    def update
      @objects.each { |object| object.update }
      size = @objects.size if LOG
      @objects = @objects.keep_if { |object| object.active }
      puts "removing #{size - @objects.size}" if LOG and size != @objects.size
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
