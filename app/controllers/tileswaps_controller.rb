class TileswapsController < ApplicationController
  def create
    operation = SwapTiles.new(params[:game_id],
                              params[:tiles].map { |t| Tile.new(t["letter"], t["blank"]) },
                              "steve")

    if operation.call
      render json: GamePresenter.new(params[:game_id], operation.game, "steve")
    else
      render status: 422, json: { errors: ["That swap is not valid"] }
    end
  end
end
