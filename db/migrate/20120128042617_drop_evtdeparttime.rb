class DropEvtdeparttime < ActiveRecord::Migration
  def up
    remove_column :events, :evtdeparttime
  end

  def down
    add_column :events, :evtdeparttime, :string
  end
end
