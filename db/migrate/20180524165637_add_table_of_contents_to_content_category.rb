class AddTableOfContentsToContentCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :content_categories, :table_of_contents, :boolean, default: false
  end
end
