class TurnPassesController < ApplicationController
  def create
    user_id = 1
    begin
      game_session = GameStore.load_session!(params[:game_id], user_id) do |actions|
        actions.pass_turn
      end
      render json: GameSessionPresenter.new(params[:game_id], game_session)
    rescue GameStore::OperationFailed
      render status: 422, json: { errors: ["You cannot pass the turn"] }
    end
  end
end
