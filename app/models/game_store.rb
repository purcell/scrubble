module GameStore
  STANDARD_DICTIONARY = ['ROFL', 'ZOMG', 'LOLZ', 'GET', 'KIT', 'HOT', 'ROOF']

  class OperationFailed < StandardError; end

  def self.load_session!(game_id, user_id)
    game_record = Storage::Game.find(game_id)
    game_record.with_lock do
      player_record = game_record.players.find_by_user_id(user_id)

      player = Player.new(player_record.user.name)
      players = game_record.players.order(:order).map { |p| Player.new(p.user.name) }
      game = Game.new(Bag.new(game_record.bag), players, STANDARD_DICTIONARY)

      replay_history(game, game_record)
      GameSession.new(game, player).tap do |session|
        if block_given?
          yield ChainedActions.new(session, GameSessionOps.new(game_record, player_record))
        end
      end
    end
  end

  private

  def self.replay_history(game, game_record)
    game_record.turns.each do |turn|
      played_tiles = turn.tile_uses.each.with_object({}) do |tile_use, tiles|
        tiles[Position.new(tile_use.x, tile_use.y)] = Tile.new(tile_use.letter, tile_use.blank?)
      end
      swapped_tiles = turn.tile_swaps.map do |tile|
        Tile.new(tile.letter, tile.blank?)
      end
      GameSession.new(game, Player.new(turn.player.user.name)).tap do |session|
        if played_tiles.any?
          session.play_tiles(played_tiles)
        elsif swapped_tiles.any?
          session.swap_tiles(swapped_tiles)
        else
          session.pass_turn
        end
      end
    end
  end

  class ChainedActions
    def initialize(model, model_ops)
      @model = model
      @model_ops = model_ops
    end

    def method_missing(symbol, *args)
      unless @model.respond_to?(symbol) && @model_ops.respond_to?(symbol)
        raise ArgumentError, "unsupported operation #{symbol}"
      end
      @model.send(symbol, *args).tap do |success|
        raise OperationFailed unless success
        @model_ops.send(symbol, *args)
      end
    end
  end

  class GameSessionOps
    def initialize(game_record, player_record)
      @game_record = game_record
      @player_record = player_record
    end

    def play_tiles(played_tiles)
      @game_record.turns.create!(
        player: @player_record,
        tile_uses: played_tiles.map do |pos, tile|
          Storage::TileUse.new(x: pos.x, y: pos.y, letter: tile.letter, blank: tile.blank?)
        end
      )
    end

    def swap_tiles(tiles)
      @game_record.turns.create!(
        player: @player_record,
        tile_swaps: tiles.map do |tile|
          Storage::TileSwap.new(letter: tile.letter, blank: tile.blank?)
        end
      )
    end

    def pass_turn
      @game_record.turns.create!(player: @player_record)
    end
  end
end
