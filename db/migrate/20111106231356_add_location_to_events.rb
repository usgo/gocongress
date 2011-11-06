class AddLocationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :location, :string, :limit => 50
  end
end
