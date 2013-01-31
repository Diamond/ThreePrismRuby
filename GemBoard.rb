class GemBoard
  attr_reader :score

  BOARD_WIDTH  = 10
  BOARD_HEIGHT = 10
  MATCH_POINTS = 10

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

    @blankGem = GameGem.new
  end

  def initGems
    @gemList = [:black, :red, :blue, :magenta, :green, :yellow, :cyan, :white]
  end

  def correctBoard(initial=false)
    doneGen = false
    while not doneGen
      @multiplier += 1
      searchMatches
      doneGen = complete?
      generateBoard
    end
    @score      += @tempScore * @multiplier unless initial
    @tempScore   = 0
    @multiplier  = 0
  end

  def initBoard
    for y in 0..BOARD_HEIGHT
      @board << []
    end
  end

  def loop_board
    return unless block_given?
    for y in 0..BOARD_HEIGHT
      for x in 0..BOARD_WIDTH
        yield x, y
      end
    end
  end

  def resetBoard
    loop_board { |x,y| @board[y][x] = nil }
  end

  def generateBoard
    loop_board do |x,y|
      value = rand(1..6)
      @board[y][x] = GameGem.new(@gemList[value], value, x, y) if @board[y][x].nil?
    end
  end

  def gravity
    for y in (BOARD_HEIGHT-1).step(1, -1)
      for x in 0..BOARD_WIDTH
        if @board[y][x].nil?
          for dy in y.step(0, -1)
            next if @board[dy][x] == nil
            @board[y][x] = @board[dy][x]
            @board[dy][x] = nil
          end
        end
      end
    end
    
    generateBoard
    correctBoard
    puts "Game over! Score: #{@score}" unless validMovesRemaining
  end

  def update
    loop_board { |x,y| @board[y][x].update x, y if @board[y][x].is_a? GameGem }
  end

  def draw(surface)
    loop_board { |x,y| @board[y][x].draw surface if @board[y][x].is_a? GameGem }
    @cursor.blit surface, [@selectedX * 64, @selectedY * 64] if @selected
  end

  def searchMatches
    loop_board do |x,y|
      next if @board[y][x].nil?
      matches = countMatches x, y
      fill(x, y, @board[y][x]) if matches >= 3
    end
  end

  def countMatches(x, y)
    matches  = 1
    matches += 1 if x - 1 >= 0           and @board[y][x-1] == @board[y][x]
    matches += 1 if x + 1 < BOARD_WIDTH  and @board[y][x+1] == @board[y][x]
    matches += 1 if y - 1 >= 0           and @board[y-1][x] == @board[y][x]
    matches += 1 if y + 1 < BOARD_HEIGHT and @board[y+1][x] == @board[y][x]
    matches
  end

  def fill(x, y, searchFor)
    @tempScore   += 10
    @board[y][x]  = nil
    fill(x-1, y, searchFor) if x-1 >= 0           and @board[y][x-1] == searchFor
    fill(x+1, y, searchFor) if x+1 < BOARD_WIDTH  and @board[y][x+1] == searchFor
    fill(x, y-1, searchFor) if y-1 >= 0           and @board[y-1][x] == searchFor
    fill(x, y+1, searchFor) if y+1 < BOARD_HEIGHT and @board[y+1][x] == searchFor
  end

  def complete?
    loop_board { |x,y| return false if @board[y][x].nil? }
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
    matches  = 0
    matches += 1 unless exclude == :north or northMatch(x, y, gem)
    matches += 1 unless exclude == :south or southMatch(x, y, gem)
    matches += 1 unless exclude == :east  or eastMatch(x, y, gem)
    matches += 1 unless exclude == :west  or westMatch(x, y, gem)
    matches
  end

  def do_swap(x1, y1, x2, y2)
    return unless block_given?
    temp1 = @board[y1][x1]
    temp2 = @board[y2][x2]
    @board[y1][x1] = temp2
    @board[y2][x2] = temp1
    matches = [checkForMatches(x1, y1, temp1), checkForMatches(x2, y2, temp2)].max
    yield temp1, temp2, matches
  end

  def swap(x1, y1, x2, y2)
    do_swap(x1, y1, x2, y2) do |temp1, temp2, matches|
      if matches < 3
        @board[y1][x1] = temp1
        @board[y2][x2] = temp2
      else
        searchMatches
        gravity
      end
    end
  end

  def fakeSwap(x1, y1, x2, y2)
    do_swap(x1, y1, x2, y2) do |temp1, temp2, matches|
      @board[y1][x1] = temp1
      @board[y2][x2] = temp2
      return matches >= 3
    end
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
