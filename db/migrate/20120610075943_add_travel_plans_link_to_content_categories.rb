class AddTravelPlansLinkToContentCategories < ActiveRecord::Migration
  def change
    add_column :content_categories, :travel_plans_link, :boolean, \
      :null => false, :default => false
  end
end
