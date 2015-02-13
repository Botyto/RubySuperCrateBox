require "minitest/autorun"
include MiniTest

require_relative "test_tools.rb"
require_relative "../common.rb"
require_relative "../gameObject.rb"
require_relative "../player.rb"

class SmokePuffs
  def self.create_puffs(*args); end
end

class TestPlayer < Test
  include TestTools

  
end
