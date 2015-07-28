class PlacementsController < ApplicationController
  def create
    begin
      game_session = GameStore.load_session!(params[:game_id], session[:user_id]) do |actions|
        actions.play_tiles(params[:played_tiles].each.with_object({}) do |p, played|
                             played[Position.new(p["x"], p["y"])] = Tile.new(p["letter"], p["blank"])
                           end)
      end
      render json: GameSessionPresenter.new(params[:game_id], game_session)
    rescue GameStore::OperationFailed
      render status: 422, json: { errors: ["That placement is not valid"] }
    end
  end
end
