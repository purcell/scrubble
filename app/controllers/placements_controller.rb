class PlacementsController < ApplicationController
  def create
    player_name = "steve"
    begin
      game = GameStore.load!(params[:game_id]) do |actions|
        actions.apply_placement("steve",
                                params[:played_tiles].each.with_object({}) do |p, played|
                                  played[Position.new(p["x"], p["y"])] = Tile.new(p["letter"], p["blank"])
                                end)
      end
      render json: GamePresenter.new(params[:game_id], game, player_name)
    rescue GameStore::OperationFailed
      render status: 422, json: { errors: ["That placement is not valid"] }
    end
  end
end
