class Game
  attr_accessor :board
  attr_accessor :score
  attr_reader :tray
  attr_reader :bag

  def initialize
    @bag = Bag.new

    @board = Board.new(['ROFL', 'ZOMG', 'LOLZ', 'GET'])
    @board.place(Position.new(8, 8), Tile.new("L"))
    @board.place(Position.new(9, 8), Tile.new("O"))
    @board.place(Position.new(10, 8), Tile.new("L"))

    @board.place(Position.new(11, 8), Tile.new("Z"))
    @board.place(Position.new(11, 9), Tile.new("O", true))
    @board.place(Position.new(11, 10), Tile.new("M"))
    @board.place(Position.new(11, 11), Tile.new("G"))

    @board.place(Position.new(9, 7), Tile.new("R"))
    @board.place(Position.new(9, 9), Tile.new("F"))
    @board.place(Position.new(9, 10), Tile.new("L"))

    @tray = Tray.new("KITEH".chars.map { |l| Tile.new(l) } + [Tile.new(nil, true), nil])

    @score = 0
  end
end
