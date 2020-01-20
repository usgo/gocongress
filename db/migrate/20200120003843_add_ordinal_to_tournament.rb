class AddOrdinalToTournament < ActiveRecord::Migration[5.0]
  def change
    add_column :tournaments, :ordinal, :integer, null: false, default: 1
  end
end
