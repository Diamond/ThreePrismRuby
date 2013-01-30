#!/usr/bin/env ruby

require "rubygems"
require "rubygame"

include Rubygame

# ThreePrism includes
require_relative "GameGem"
require_relative "GemBoard"

class ThreePrism
  def initialize
    @screen = Rubygame::Screen.new [640, 640], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
    @screen.title = "threeprism"

    @queue = Rubygame::EventQueue.new
    @clock = Rubygame::Clock.new
    @clock.target_framerate = 60

    @board = GemBoard.new
  end

  def run!
    loop do
      update
      draw
      @clock.tick
    end
  end

  def update
    @queue.each do |ev|
      case ev
        when Rubygame::MouseDownEvent
          if ev.button == Rubygame::MOUSE_LEFT
            @board.checkForInput ev.pos[0], ev.pos[1]
          end
        when Rubygame::QuitEvent
          Rubygame.quit
          exit
      end
    end
  end

  def draw
    @screen.fill [0, 0, 0]
    @board.draw @screen
    @screen.flip
  end
end

game = ThreePrism.new
game.run!
