require_relative "gameObject.rb"
require_relative "resourceManager.rb"

class Player < GameObject
  def initialize
    super
    set_sprite "player"
  end
end