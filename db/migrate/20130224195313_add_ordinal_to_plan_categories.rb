class AddOrdinalToPlanCategories < ActiveRecord::Migration
  def change
    add_column :plan_categories, :ordinal, :integer, :null => false, :default => 1
  end
end
