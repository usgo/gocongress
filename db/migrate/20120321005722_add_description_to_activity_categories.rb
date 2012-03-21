class AddDescriptionToActivityCategories < ActiveRecord::Migration
  def change
    add_column :activity_categories, :description, :string, :limit => 500
  end
end
