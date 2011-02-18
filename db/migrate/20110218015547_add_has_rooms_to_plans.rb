class AddHasRoomsToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :has_rooms, :boolean, { :null => false, :default => false }
  end

  def self.down
    remove_column :plans, :has_rooms
  end
end
