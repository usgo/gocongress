class AddTimeToEventDate < ActiveRecord::Migration
  def self.up
    add_column :events, :start, :datetime
  end

  def self.down
    remove_column :events, :start
  end
end
