class AddSingleToPlanCategories < ActiveRecord::Migration
  def change
    add_column :plan_categories, :single, :boolean, :null => false, :default => false
  end
end
