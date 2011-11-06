class AddLocationToTournaments < ActiveRecord::Migration
  def change
    add_column :tournaments, :location, :string, :limit => 50
  end
end
