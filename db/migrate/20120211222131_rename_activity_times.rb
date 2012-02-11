class RenameActivityTimes < ActiveRecord::Migration
  def change
    rename_column :activities, :leave, :leave_time
    rename_column :activities, :return, :return_time
  end
end
