class AddUrlAndPhoneToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :phone, :string, :limit => 20
    add_column :activities, :url, :string, :limit => 200
  end
end
