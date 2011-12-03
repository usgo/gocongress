class AlterEventsAlterCategoryNotNullable < ActiveRecord::Migration
  def up
    change_column :events, :event_category_id, :integer, :null => false
  end
  
  def down
    change_column :events, :event_category_id, :integer, :null => true
  end
end
