require "Rubygame"

class GameObject
  attr_accessor :x, :y, :width, :height, :image

  def initialize(color="black.png", x=0, y=0)
    @image  = Surface.load color + ".png"
    @x      = x
    @y      = y
    @width  = @image.width
    @height = @image.height
  end

  def update
  end

  def draw(surface)
    @image.blit surface, [@x, @y]
  end

  def handle_event(event)
  end
end
