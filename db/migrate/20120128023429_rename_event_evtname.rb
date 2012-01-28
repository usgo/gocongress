class RenameEventEvtname < ActiveRecord::Migration
  def up
    rename_column :events, :evtname, :name
  end

  def down
    rename_column :events, :name, :evtname
  end
end
