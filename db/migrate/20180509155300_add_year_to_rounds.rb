class AddYearToRounds < ActiveRecord::Migration[5.0]
  def change
    add_column :rounds, :year, :integer
  end
end
