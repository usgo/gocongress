class RemovePlayersOnlyFromDiscounts < ActiveRecord::Migration
  def up
    remove_column :discounts, :players_only
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
