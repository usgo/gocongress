class ChangeAttendeesLimitCountry < ActiveRecord::Migration
  def self.up
    change_column :attendees, :country, :string, :limit => 2
  end

  def self.down
    change_column :attendees, :country, :string
  end
end
