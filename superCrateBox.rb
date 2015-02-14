require_relative "gameWindow.rb"

Game = GameWindow.new(ARGV.include? "-f")
Game.show
