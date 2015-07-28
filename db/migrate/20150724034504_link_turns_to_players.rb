class LinkTurnsToPlayers < ActiveRecord::Migration
  def change
    change_table :turns do |t|
      t.references :player
    end
    remove_column :turns, :player_name
  end
end
