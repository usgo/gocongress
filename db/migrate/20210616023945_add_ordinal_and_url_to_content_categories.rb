class AddOrdinalAndUrlToContentCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :content_categories, :ordinal, :integer, null: false, default: 1
    add_column :content_categories, :url, :string
  end
end
