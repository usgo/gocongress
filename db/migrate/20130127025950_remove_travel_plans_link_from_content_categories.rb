class RemoveTravelPlansLinkFromContentCategories < ActiveRecord::Migration
  def up
    remove_column :content_categories, :travel_plans_link
  end

  def down
    add_column :content_categories, :travel_plans_link, :boolean,
      :null => false, :default => false
  end
end
