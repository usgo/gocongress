class AddMaxQuantityToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :max_quantity, :integer, { :null => false, :default => 1 }
  end

  def self.down
    remove_column :plans, :max_quantity
  end
end
