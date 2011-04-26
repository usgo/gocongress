class RemoveFlagsFromPlans < ActiveRecord::Migration
  def self.up
    remove_column :plans, :has_meals
    remove_column :plans, :has_rooms
  end

  def self.down
    add_column :plans, :has_meals, :boolean, { :null => false, :default => false }
    add_column :plans, :has_rooms, :boolean, { :null => false, :default => false }
  end
end
