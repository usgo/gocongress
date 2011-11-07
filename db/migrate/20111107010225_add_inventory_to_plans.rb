class AddInventoryToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :inventory, :integer
  end
end
