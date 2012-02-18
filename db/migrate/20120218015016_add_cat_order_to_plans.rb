class AddCatOrderToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :cat_order, :integer, null: false, default: 0
  end
end
