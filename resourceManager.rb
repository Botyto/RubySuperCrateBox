require_relative "common.rb"
require_relative "level.rb"
require_relative "gameWindow.rb"

class Sprite
  attr_accessor :name, :image, :tiled, :z, :width, :height, :color, :ascii

  def num_frames
    @image.size
  end

  def aabb(offset = Point.new)
    Rectangle.new(-@width/2, -@height/2, @width, @height) + offset
  end

  def draw_ascii(x, y)
    GameWindow.set_color @color
    base = Point.new((x/GameWindow.game.width).floor, (y/GameWindow.game.height).floor)

    @ascii.split('\n').each_with_index do |line, number|
      GameWindow.move_cursor(base.x, base.y + number)
      print line
    end
  end

  def draw_frame(frame, x, y, z, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default)
    if tiled then
      image[frame.floor % num_frames].draw(x, y, z, factor_x, factor_y, color, mode) 
    else
      image.draw(x, y, z, factor_x, factor_y, color, mode)
    end
    draw_ascii x, y
  end

  def draw_rot_frame(frame, x, y, z, angle, center_x = 0.5, center_y = 0.5, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default) 
    if tiled then
      image[frame.floor % num_frames].draw_rot(x, y, z, angle, center_x, center_y, factor_x, factor_y, color, mode) 
    else
      image.draw_rot(x, y, z, angle, center_x, center_y, factor_x, factor_y, color, mode) 
    end
    draw_ascii x, y
  end

  def draw(x, y, z, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default) 
    image.draw(x, y, z, factor_x, factor_y, color, mode)
    draw_ascii x, y
  end

  def draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default) 
    image.draw_rot(x, y, z, angle, center_x, center_y, factor_x, factor_y, color, mode) 
    draw_ascii x, y
  end
end

class ResourceManager
  class << self
    attr_reader :sprites, :sounds, :scenes, :game
    
    def initialize(game)
      @game = game
    end

    def generate_filenames
      @scene_filenames  = ["level1"]
      @sprite_filenames = ["wall", "player", "fire", "enemy", "crate"]
      @sound_filenames  = []
    end

    def load
      generate_filenames
    
      @levels = Hash.new
      @sprites = Hash.new
      @sounds = Hash.new
      @scenes = Hash.new
      
      @scene_filenames.each  { |file| load_scene_file (file) }
      @sprite_filenames.each { |file| load_sprite_file(file) }
      @sound_filenames.each  { |file| load_sound_file (file) }
    end
    
    def load_scene_file(filename)
      scene = parse_class(DATA + filename + EXT_SCENE, Scene)
      scene.parse
      debug_log "Parse scene #{filename}"
      @scenes[filename] = scene
      debug_log "Load scene \"#{filename}\""
    end
    
    def load_sprite_file(filename)
      sprite = parse_class(DATA + filename + EXT_SPRITE, Sprite)

      if sprite.tiled then
        sprite.image = Image.load_tiles(
            @game,
            DATA + sprite.name,
            sprite.width,
            sprite.height,
            true)
      else
        sprite.image = Image.new(@game, DATA + sprite.name, false)
      end

      @sprites[filename] = sprite
      debug_log "Load sprite \"#{filename}\""
      debug_log sprite
    end

    def load_sound_file(filename)
      # not implemented
      debug_log "Load sound \"#{filename}\""
    end
  end
end
