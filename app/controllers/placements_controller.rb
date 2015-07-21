class PlacementsController < ApplicationController
  def create
    operation = PlayTiles.new(params[:game_id],
                              params[:played_tiles].each.with_object({}) do |p, played|
                                played[Position.new(p["x"], p["y"])] = Tile.new(p["letter"], p["blank"])
                              end,
                              "steve")

    if operation.call
      render json: GamePresenter.new(params[:game_id], operation.game, "steve")
    else
      render status: 422, json: { errors: ["That placement is not valid"] }
    end
  end
end
