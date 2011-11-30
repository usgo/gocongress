class CreateContentCategories < ActiveRecord::Migration  
  def change
    create_table :content_categories do |t|
      t.integer :year, :null => false
      t.string :name, :limit => 50
      t.timestamps
    end
  end
end
