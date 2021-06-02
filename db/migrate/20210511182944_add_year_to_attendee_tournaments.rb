class AddYearToAttendeeTournaments < ActiveRecord::Migration[5.1]
  def change
    add_column :attendee_tournaments, :year, :integer
  end
end
