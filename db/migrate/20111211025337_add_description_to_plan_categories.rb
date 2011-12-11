class AddDescriptionToPlanCategories < ActiveRecord::Migration
  def change
    add_column :plan_categories, :description, :string
  end
end
