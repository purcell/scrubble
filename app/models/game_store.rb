module GameStore
  def self.load!(game_id)
    game_record = Storage::Game.find(game_id)
    Game.new(Bag.new(game_record.bag), ["steve"]).tap do |game|
      game_record.turns.each do |turn|
        played_tiles = turn.tile_uses.each.with_object({}) do |tile_use, tiles|
          tiles[Position.new(tile_use.x, tile_use.y)] = Tile.new(tile_use.letter, tile_use.blank?)
        end
        game.apply_placement(turn.player_name, played_tiles)
      end
    end
  end

  def self.save_placement!(game_id, played_tiles, player_name)
    Storage::Game.find(game_id).tap do |game|
      game.turns.create!(
        player_name: player_name,
        tile_uses: played_tiles.map do |pos, tile|
          Storage::TileUse.new(x: pos.x, y: pos.y, letter: tile.letter, blank: tile.blank?)
        end
      )
    end
  end
end
