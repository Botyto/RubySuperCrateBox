require_relative "gameObject.rb"

class Enemy < GameObject
end

class Spawner < GameObject
end

class Fire < Enemy
  def intialize(position)
    super position
    @sprite = ResourceManager.sprites["fire"]
  end
end
