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
    @cursor     = Surface.load "selected.png"

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
        @board[y][x] = rand(1..7) if @board[y][x] == 0
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
      @cursor.blit surface, [@selectedX * 64, @selectedY * 64]
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

  def checkForMatches(x, y, gem)
    matches = 1
    if northMatch x, y, gem
      ny = y - 1
      matches += allMatch(x, ny, gem, :south) + 1
    end
    if southMatch x, y, gem
      ny = y + 1
      matches += allMatch(x, ny, gem, :north) + 1
    end
    if westMatch x, y, gem
      nx = x - 1
      matches += allMatch(nx, y, gem, :east) + 1
    end
    if eastMatch x, y, gem
      nx = x + 1
      matches += allMatch(nx, y, gem, :west) + 1
    end
    matches
  end
  
  def northMatch(x, y, gem)
    y > 0 and @board[y-1][x] == gem
  end

  def southMatch(x, y, gem)
    y < BOARD_HEIGHT - 1 and @board[y+1][x] == gem
  end

  def eastMatch(x, y, gem)
    x < BOARD_WIDTH - 1 and @board[y][x+1] == gem
  end

  def westMatch(x, y, gem)
    x > 0 and @board[y][x-1] == gem
  end

  def allMatch(x, y, gem, exclude=:none)
    matches = 0
    matches += 1 unless exclude == :north or northMatch(x, y, gem)
    matches += 1 unless exclude == :south or southMatch(x, y, gem)
    matches += 1 unless exclude == :east or eastMatch(x, y, gem)
    matches += 1 unless exclude == :west or westMatch(x, y, gem)
    matches
  end

  def swap(x1, y1, x2, y2)
    temp1 = @board[y1][x1]
    temp2 = @board[y2][x2]
    @board[y1][x1] = temp2
    @board[y2][x2] = temp1
    matches = [checkForMatches(x2, y2, @board[y2][x2]), checkForMatches(x1, y1, @board[y1][x1])].max
    if matches < 3
      @board[y1][x1] = temp1
      @board[y2][x2] = temp2
    else
      beginMatchSearch
      gravity
    end
  end

  def fakeSwap(x1, y1, x2, y2)
    temp1 = @board[y1][x1]
    temp2 = @board[y2][x2]
    @board[y1][x1] = temp2
    @board[y2][x2] = temp1
    matches = [checkForMatches(x2, y2, @board[y2][x2]), checkForMatches(x1, y1, @board[y1][x1])].max
    @board[y1][x1] = temp1
    @board[y2][x2] = temp2
    matches >= 3
  end

  def validMovesRemaining
    for y in 1...(BOARD_HEIGHT-1)
      for x in 1...(BOARD_WIDTH-1)
        return true if fakeSwap x, y, x, y-1
        return true if fakeSwap x, y, x, y+1
        return true if fakeSwap x, y, x-1, y
        return true if fakeSwap x, y, x+1, y
      end
    end
  end
end
