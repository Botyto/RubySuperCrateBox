LOG = true
GRAVITY = 0.1

class Point
  attr_accessor :x, :y
  
  def initialize(x = 0, y = 0)
    @x, @y = x, y
  end
  
  def +(amount)
    if amount.is_a? Point then
      Point.new(@x + amount.x, @y + amount.y)
    elsif amount.is_a? Numeric then
      Point.new(@x + amount, @y + amount)
    end
  end
  
  def -(amount)
    if amount.is_a? Point then
      Point.new(@x - amount.x, @y - amount.y)
    elsif amount.is_a? Numeric then
      Point.new(@x - amount, @y - amount)
    end
  end
  
  def *(number)
    @x *= number
    @y *= number
  end
  
  def /(number)
    @x /= number
    @y /= number
  end
  
  def length
    Math.sqrt(@x*@x + @y*@y)
  end
  
  def snap_to_grid(w, h)
    Point.new((@x/w).round * w, (@y/h).round * h)
  end
  
  def snap_to_grid!(w, h)
    @x = (@x/w).round * w
    @y = (@y/h).round * h
  end
end

class Rectangle
  attr_accessor :x, :y, :w, :h
  
  def initialize(x = 0, y = 0, w = 0, h = 0)
    @x, @y, @w, @h = x, y, w, h
  end
  
  def x2
    x + w
  end
  
  def y2
    y + h
  end
  
  def area
    w*h
  end

  alias :width :w
  alias :height :h
  alias :x1 :x
  alias :y1 :y
  alias :left :x
  alias :top :y
  alias :right :x2
  alias :bottom :y2
  
  def point_inside?(point)
    if point.is_a? Point then
      point.x >= x1 and point.y >= y1 and point.x <= x2 and point.y <= y2
    else
      false
    end
  end
  
  def intersects?(other)
    if other.is_a? Rectangle then
      not (other.x2 < x1 or other.y2 < y1 or other.x1 > x2 or other.y1 > y2)
    else
      false
    end
  end

  def +(point)
    if point.is_a? Point then
      Rectangle.new(@x + point.x, @y + point.y, @w, @h)
    end
  end
end

def parse_class(filename, klass)
  lines = File.readlines(filename).map &:chomp
  result = klass.new

  lines.each do |line|
    name, value, type = *(line.split ':')
    case type
      when "exec"
        result.send "#{name}=value"
      when "int"
        result.send "#{name}=", value.to_i
      when "bool"
        result.send "#{name}=", value == "true"
      when "sym"
        result.send "#{name}=", value.to_sym
      when "nil"
        result.send "#{name}=", nil
      else
        result.send "#{name}=", value
    end
  end

  result
end

def debug_log(content)
  return if !LOG

  if content.is_a? String then
    puts content
  else
    puts "\n" + content.inspect + "\n\n"
  end
end