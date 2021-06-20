class AddPlayersOnlyToDiscounts < ActiveRecord::Migration
  def change
    add_column :discounts, :players_only, :boolean, { :null => false, :default => false }
  end
end
