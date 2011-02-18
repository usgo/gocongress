class AddHasMealsToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :has_meals, :boolean, { :null => false, :default => false }
  end

  def self.down
    remove_column :plans, :has_meals
  end
end
