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
