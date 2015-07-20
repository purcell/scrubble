    class PositionPresenter
    def initialize(position)
      @position = position
    end

    def as_json(options=nil)
      { x: @position.x, y: @position.y }
    end
  end
