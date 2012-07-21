class AddVenueToYear < ActiveRecord::Migration
  def change
    add_column :years, :venue_url, :string
    add_column :years, :venue_name, :string
    add_column :years, :venue_address, :string
    add_column :years, :venue_city, :string
    add_column :years, :venue_state, :string, :limit => 2
    add_column :years, :venue_zip, :string, :limit => 10
    add_column :years, :venue_phone, :string, :limit => 20
  end
end
