module GameStore
  STANDARD_DICTIONARY = ['ROFL', 'ZOMG', 'LOLZ', 'GET', 'KIT', 'HOT', 'ROOF']

  class OperationFailed < StandardError; end

  def self.load!(game_id)
    game_record = Storage::Game.find(game_id)
    Game.new(Bag.new(game_record.bag), ["steve"], STANDARD_DICTIONARY).tap do |game|
      # TODO: locking
      game_record.turns.each do |turn|
        played_tiles = turn.tile_uses.each.with_object({}) do |tile_use, tiles|
          tiles[Position.new(tile_use.x, tile_use.y)] = Tile.new(tile_use.letter, tile_use.blank?)
        end
        if played_tiles.any?
          game.apply_placement(turn.player_name, played_tiles)
        end
        swapped_tiles = turn.tile_swaps.map do |tile|
          Tile.new(tile.letter, tile.blank?)
        end
        if swapped_tiles.any?
          game.swap_tiles(turn.player_name, swapped_tiles)
        end
      end
      yield Multiplexer.new(game, GameOps.new(game_record)) if block_given?
    end
  end

  private

  class Multiplexer
    def initialize(game, game_ops)
      @game = game
      @game_ops = game_ops
    end

    def method_missing(symbol, *args)
      unless @game.respond_to?(symbol) && @game_ops.respond_to?(symbol)
        raise ArgumentError, "unsupported operation #{symbol}"
      end
      @game.send(symbol, *args).tap do |success|
        raise OperationFailed unless success
        @game_ops.send(symbol, *args)
      end
    end
  end

  class GameOps
    def initialize(game_record)
      @game_record = game_record
    end

    def apply_placement(player_name, played_tiles)
      @game_record.turns.create!(
        player_name: player_name,
        tile_uses: played_tiles.map do |pos, tile|
          Storage::TileUse.new(x: pos.x, y: pos.y, letter: tile.letter, blank: tile.blank?)
        end
      )
    end

    def swap_tiles(player_name, tiles)
      @game_record.turns.create!(
        player_name: player_name,
        tile_swaps: tiles.map do |tile|
          Storage::TileSwap.new(letter: tile.letter, blank: tile.blank?)
        end
      )
    end
  end
end
