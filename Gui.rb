class Gui
  def initialize
    @background = Surface.load "scorebg.png"
    @font = Rubygame::TTF.new "visitor1.ttf", 16
  end

  def draw(surface, score)
    @background.blit surface, [0, 640]
    image = @font.render "Score: #{score.to_s}", true, [255, 255, 255]
    image.blit surface, [20, 660]
  end
end
