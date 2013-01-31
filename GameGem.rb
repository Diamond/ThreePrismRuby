class GameGem
  attr_reader :value

  def initialize(color=:black, value=0, x=0, y=0)
    @image   = Surface.load color.to_s + ".png"
    @value   = value
    @board_x = x
    @board_y = y
    @x       = @board_x * @image.width
    @y       = @board_y * @image.height
  end

  def update(x, y)
    @board_x = x
    @board_y = y
    @x = @board_x * 64
    @y = @board_y * 64
  end

  def draw(surface)
    @image.blit surface, [@x, @y]
  end

  def ==(other)
    unless other.nil?
      return @value == other.value
    else
      return false
    end
  end
end
