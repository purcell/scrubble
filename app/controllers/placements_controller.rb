class PlacementsController < ApplicationController

  def create
    game = Game.new
    requested_placements = params[:placements]
    placement = Placement.new(game.board)
    requested_placements.each do |p|
      placement.place(Position.new(p["x"], p["y"]), Tile.new(p["letter"], p["blank"]))
    end
    if placement.valid?
      game.score += placement.score
      game.board = placement.new_board
      game.tray.replace_tiles(game.bag, placement.tiles)
      render json: GamePresenter.new(game)
    else
      render status: 422, json: { errors: ["That placement is not valid"] }
    end
  end
end
