class AlterActivitiesLengthenNotes < ActiveRecord::Migration
  def up
    change_column :activities, :notes, :string, :limit => 2000
  end

  def down
    change_column :activities, :notes, :string, :limit => 250
  end
end
