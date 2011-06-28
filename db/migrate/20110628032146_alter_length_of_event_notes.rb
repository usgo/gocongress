class AlterLengthOfEventNotes < ActiveRecord::Migration
  def up
    change_column :events, :notes, :string, :limit => 250
  end

  def down
    change_column :events, :notes, :string
  end
end
