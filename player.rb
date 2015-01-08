require_relative "gameObject.rb"
require_relative "resourceManager.rb"

class Player < GameObject
  def initialize(position)
    super position
    @sprite = ResourceManager.sprites["player"]
  end

  def update
    super
  end
end