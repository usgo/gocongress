class RemoveUniqueIndexAttendeesOnAgaIdAndYear < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        remove_index :attendees, [:aga_id, :year]
      end

      dir.down do
        add_index :attendees, [:aga_id, :year], unique: true
      end
    end
  end
end
