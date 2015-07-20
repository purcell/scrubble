class GamesController < ApplicationController

  def show
    @game = GamePresenter.new(Game.new)
  end

end
