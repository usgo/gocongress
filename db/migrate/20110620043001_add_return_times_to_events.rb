class AddReturnTimesToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :return_depart_time, :time
    add_column :events, :return_arrive_time, :time
  end

  def self.down
    remove_column :events, :return_depart_time
    remove_column :events, :return_arrive_time
  end
end
