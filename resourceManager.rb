require_relative "common.rb"
require_relative "level.rb"
require_relative "gameWindow.rb"

class Sound
  attr_accessor :type, :file
  attr_reader :sound

  def load
    if @type == TYPE_SONG then
      @sound = Song.new(GameWindow.game, DATA + file)
    elsif @type == TYPE_SFX then
      @sound = Sample.new(GameWindow.game, DATA + file)
    end
  end

  def play
    if @type == TYPE_SONG then
      @sound.play true
      debug_log "Playing song"
    elsif @type == TYPE_SFX then
      @sound.play
      debug_log "Playing sfx"
    end
  end

  def pause
    @sound.pause if @type == TYPE_SONG and !@sound.playing?
    debug_log "Pause sound"
  end

  def stop
    @sound.stop if @type == TYPE_SONG and !@sound.playing?
    debug_log "Stop sound"
  end
end

class FontFactory
  attr_reader :name

  def initialize(name)
    @name = name
    @sizes = Hash.new
    load
  end

  def filename
    DATA + @name + EXT_FONT
  end

  def [](height)
    load(height) if !@sizes.has_key? height
    @sizes[height]
  end

  def load(height = 10)
    return if @sizes.has_key? height
    debug_log "Load font \"#{name}\" at size #{height}", YELLOW
    @sizes[height] = Font.new(GameWindow.game, filename, height)
  end

  def draw(height, text, x, y, z, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default)
    self[height].draw(text, x + 1, y + 1, z, factor_x, factor_y, Color::BLACK, mode)
    self[height].draw(text, x, y, z, factor_x, factor_y, color, mode)
  end

  def draw_rel(height, text, x, y, z, rel_x, rel_y, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default)
    self[height].draw_rel(text, x + 1, y + 1, z, rel_x, rel_y, factor_x, factor_y, Color::BLACK, mode)
    self[height].draw_rel(text, x, y, z, rel_x, rel_y, factor_x, factor_y, color, mode)
  end
end

class Sprite
  attr_accessor :name, :image, :tiled, :z, :width, :height, :color, :ascii

  def num_frames
    @image.count if @image.is_a? Array
    1
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

  def draw_rot_frame(frame, x, y, z, angle, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default) 
    if tiled then
      image[frame.floor % num_frames].draw_rot(x, y, z, angle, 0.5, 0.5, factor_x, factor_y, color, mode) 
    else
      image.draw_rot(x, y, z, angle, 0.5, 0.5, factor_x, factor_y, color, mode) 
    end
    draw_ascii x, y
  end

  def draw(x, y, z, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default) 
    image.draw(x, y, z, factor_x, factor_y, color, mode)
    draw_ascii x, y
  end

  def draw_rot(x, y, z, angle, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default) 
    image.draw_rot(x, y, z, angle, 0.5, 0.5, factor_x, factor_y, color, mode) 
    draw_ascii x, y
  end
end

class ResourceManager
  class << self
    attr_reader :sprites, :sounds, :scenes, :fonts, :game
    
    def initialize(game)
      @game = game
    end

    def generate_filenames
      @scene_filenames  = ["level1", "level2", "level3"]
      @sprite_filenames = ["wall", "player", "fire", "enemy", "enemy_angry", "explosion", "crate",
        "bullet", "back_level1", "back_level2", "back_level3", "mine", "flyer", "pistol", "minigun",
        "shotgun", "machinegun"]
      @sound_filenames  = ["gameplay1", "gameplay2", "gameplay3", "shot", "explosion", "get_angry",
        "player_jump", "crate_collected", "mine_place", "shotgun_shoot", "player_die", "flyer_die",
        "zombie_die"]
      @font_filenames   = ["pixel"]
    end

    def load
      generate_filenames
    
      @levels  = Hash.new
      @sprites = Hash.new
      @sounds  = Hash.new
      @scenes  = Hash.new
      @fonts   = Hash.new
      
      @sprite_filenames.each { |file| load_sprite_file(file) }
      @sound_filenames.each  { |file| load_sound_file (file) }
      @scene_filenames.each  { |file| load_scene_file (file) }
      @font_filenames.each   { |file| load_font_file  (file) }
    end
    
    def load_scene_file(filename)
      scene = parse_class(DATA + filename + EXT_SCENE, Scene)
      scene.parse
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
    end

    def load_sound_file(filename)
      sound = parse_class(DATA + filename + EXT_SOUND, Sound)
      sound.load
      @sounds[filename] = sound
      debug_log "Load sound \"#{filename}\""
    end

    def load_font_file(filename)
      @fonts[filename] = FontFactory.new filename
    end
  end
end
