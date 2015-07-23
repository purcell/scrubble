class TileSwapsController < ApplicationController
  def create
    player_name = "steve"

    begin
      game = GameStore.load!(params[:game_id]) do |actions|
        actions.swap_tiles(player_name,
                           params[:tiles].map { |t| Tile.new(t["letter"], t["blank"]) })
      end
      render json: GamePresenter.new(params[:game_id], game, "steve")
    rescue GameStore::OperationFailed
      render status: 422, json: { errors: ["You cannot swap those tile(s)"] }
    end
  end
end
