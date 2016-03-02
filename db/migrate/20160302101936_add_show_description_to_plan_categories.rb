class AddShowDescriptionToPlanCategories < ActiveRecord::Migration
  def change
    add_column :plan_categories, :show_description, :boolean, :null => false, :default => false
  end
end
