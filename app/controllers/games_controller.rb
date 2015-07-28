class GamesController < ApplicationController
  def show
    user_id = 1
    @game = GameSessionPresenter.new(params[:id], GameStore.load_session!(params[:id], user_id))
  end
end
