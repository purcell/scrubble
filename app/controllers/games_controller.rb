class GamesController < ApplicationController
  def show
    @game = GameSessionPresenter.new(params[:id], GameStore.load_session!(params[:id], session[:user_id]))
  end
end
