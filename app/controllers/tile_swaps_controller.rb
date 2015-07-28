class TileSwapsController < ApplicationController
  def create
    user_id = 1
    begin
      game_session = GameStore.load_session!(params[:game_id], user_id) do |actions|
        actions.swap_tiles(params[:tiles].map { |t| Tile.new(t["letter"], t["blank"]) })
      end
      render json: GameSessionPresenter.new(params[:game_id], game_session)
    rescue GameStore::OperationFailed
      render status: 422, json: { errors: ["You cannot swap those tile(s)"] }
    end
  end
end
