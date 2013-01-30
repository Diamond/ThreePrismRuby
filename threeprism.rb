#!/usr/bin/env ruby

require "rubygems"
require "rubygame"

include Rubygame

# ThreePrism includes

class GameGem
  def initialize(color="black.png", x=0, y=0)
    @image  = Surface.load color.to_s + ".png"
    @x      = x
    @y      = y
    @width  = @image.width
    @height = @image.height
  end

  def update
  end

  def draw(surface, x=nil, y=nil)
    @image.blit surface, [x||@x, y||@y]
  end

  def handle_event(event)
  end
end

class GemBoard
  BOARD_WIDTH  = 10
  BOARD_HEIGHT = 10
  MATCH_POINTS = 10
  GAME_HEIGHT  = 704

  NONE  = 0
  NORTH = 1
  SOUTH = 2
  EAST  = 3
  WEST  = 4

  def initialize
    @board      = []
    @gemList    = []

    @selected   = false
    @selectedX  = 0
    @selectedY  = 0
    @cursor     = nil

    @tempScore  = 0
    @score      = 0
    @multiplier = 0
    
    initGems
    initBoard
    resetBoard

    correctBoard true
  end

  def initGems
    @gemList << GameGem.new(:black)
    @gemList << GameGem.new(:red)
    @gemList << GameGem.new(:blue)
    @gemList << GameGem.new(:magenta)
    @gemList << GameGem.new(:green)
    @gemList << GameGem.new(:yellow)
    @gemList << GameGem.new(:cyan)
    @gemList << GameGem.new(:white)
  end

  def correctBoard(initial=false)
    doneGen = false
    while not doneGen
      @multiplier += 1
      beginMatchSearch
      doneGen = complete?
      generateBoard
    end
    unless initial
      @score += @tempScore * @multiplier
      @tempScore = 0
      @multiplier = 0
    end
  end

  def initBoard
    for y in 0..BOARD_HEIGHT
      @board << []
    end
  end

  def resetBoard
    for y in 0..BOARD_HEIGHT
      for x in 0..BOARD_WIDTH
        @board[y][x] = 0
      end
    end
  end

  def generateBoard
    for y in 0..BOARD_HEIGHT
      for x in 0..BOARD_WIDTH
        @board[y][x] = rand(1..7)
      end
    end
  end

  def gravity
    for y in 0..BOARD_HEIGHT
      for x in 0..BOARD_WIDTH
        if @board[y][x] == 0
          @board[y][x] = @board[y-1][x]
          @board[y-1][x] = 0
        end
      end
    end
    generateBoard
    correctBoard
    puts "Game over! Score: #{@score}" unless validMovesRemaining
  end

  def draw(surface)
    for y in 0..BOARD_HEIGHT
      for x in 0..BOARD_WIDTH
        @gemList[@board[y][x]].draw(surface, x*64, y*64)
      end
    end
    if @selected
      # Draw cursor here
    end
  end

  def beginMatchSearch
    searchMatches
  end

  def searchMatches
    matches = 0
    for y in 0..BOARD_HEIGHT
      for x in 0..BOARD_WIDTH
        next if @board[y][x] == 0
        matches = countMatches x, y
        fill x, y, @board[y][x] if matches >= 3
      end
    end
  end

  def countMatches(x, y)
    matches = 1

    matches += 1 if x - 1 >= 0 and @board[y][x-1] == @board[y][x]
    matches += 1 if x + 1 < BOARD_WIDTH and @board[y][x+1] == @board[y][x]
    matches += 1 if y - 1 >= 0 and @board[y-1][x] == @board[y][x]
    matches += 1 if y + 1 < BOARD_HEIGHT and @board[y+1][x] == @board[y][x]
    matches
  end

  def fill(x, y, searchFor)
    @board[y][x] = 0
    fill(x-1, y, searchFor) if x-1 >= 0 and @board[y][x-1] == searchFor
    fill(x+1, y, searchFor) if x+1 < BOARD_WIDTH and @board[y][x+1] == searchFor
    fill(x, y-1, searchFor) if y-1 >= 0 and @board[y-1][x] == searchFor
    fill(x, y+1, searchFor) if y+1 < BOARD_HEIGHT and @board[y+1][x] == searchFor
  end

  def complete?
    for y in 0..BOARD_HEIGHT
      for x in 0..BOARD_WIDTH
        return false if @board[y][x] == 0
      end
    end
    return true
  end

  def checkForInput(x, y)
    if not @selected
      @selected = true
      select x, y
    else
      x1 = @selectedX
      y1 = @selectedY
      select x, y
      if x1 == @selectedX and y1 == @selectedY
        @selected = false
        return
      end
      if (x1 - @selectedX).abs <= 1 and (y1 - @selectedY).abs <= 1
        swap x1, y1, @selectedX, @selectedY
        @selected = false
      else
        @selected = true
      end
    end
  end

  def select(x, y)
    @selectedX = (x / 64).floor
    @selectedY = (y / 64).floor
  end
end

class Game
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

game = Game.new
game.run!
