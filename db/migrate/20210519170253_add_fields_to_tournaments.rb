class AddFieldsToTournaments < ActiveRecord::Migration[5.2]
  def change
    add_column :tournaments, :registration_sign_up, :boolean
    add_column :tournaments, :event_type, :integer
    add_column :tournaments, :server, :string
    add_column :tournaments, :min_rank, :integer
    add_column :tournaments, :max_rank, :integer
  end
end
