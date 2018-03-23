class AddExtendedDescriptionToPlanCategories < ActiveRecord::Migration
  def change
    add_column :plan_categories, :extended_description, :text
  end
end
