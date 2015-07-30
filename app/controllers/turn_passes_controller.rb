class TurnPassesController < ApplicationController
  def create
    begin
      game_session = GameStore.load_session!(params[:game_id], current_user_id!) do |actions|
        actions.pass_turn
      end
      render json: GameSessionPresenter.new(game_session)
    rescue GameStore::OperationFailed
      render status: 422, json: { errors: ["You cannot pass the turn"] }
    end
  end
end
