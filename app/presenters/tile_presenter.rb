class TilePresenter
  def initialize(tile)
    @tile = tile
  end

  def as_json(options=nil)
    if @tile
      { letter: @tile.letter, blank: @tile.blank?, face_value: @tile.face_value }
    end
  end
end
