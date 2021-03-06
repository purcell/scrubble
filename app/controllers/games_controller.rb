class GamesController < ApplicationController
  include Tubesock::Hijack

  def show
    @game = GameSessionPresenter.new(GameStore.load_session!(params[:id], current_user_id!))
  end

  def watch
    game_id = params[:id]
    user_id = current_user_id!
    hijack do |tubesock|
      logger.debug("Opening websocket for #{game_id}")
      subscription = GameStore.on_update(game_id) do
        logger.info("Sending update for #{game_id}")
        tubesock.send_data(GameSessionPresenter.new(GameStore.load_session!(game_id, user_id)).to_json)
      end
      tubesock.onclose do
        logger.debug("Closed websocket for #{game_id}")
        subscription.cancel
      end
    end
  end

  def new
    @users = Storage::User.available_to_play_with(current_user_id!)
  end

  def create
    redirect_to game_path(GameStore.start_game!(current_user_id!, params[:user_ids]))
  end
end
