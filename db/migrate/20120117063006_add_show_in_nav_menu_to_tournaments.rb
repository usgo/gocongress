class AddShowInNavMenuToTournaments < ActiveRecord::Migration
  def change
    add_column :tournaments, :show_in_nav_menu, :boolean, :null => false, :default => false
  end
end
