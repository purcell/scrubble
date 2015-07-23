class TurnPassesController < ApplicationController
  def create
    player_name = "steve"

    begin
      game = GameStore.load!(params[:game_id]) do |actions|
        actions.pass_turn(player_name) 
      end
      render json: GamePresenter.new(params[:game_id], game, "steve")
    rescue GameStore::OperationFailed
      render status: 422, json: { errors: ["You cannot pass the turn"] }
    end
  end
end
