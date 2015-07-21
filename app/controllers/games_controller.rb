class GamesController < ApplicationController
  def show
    @game = GamePresenter.new(params[:id], GameStore.load!(params[:id]), "steve")
  end
end
