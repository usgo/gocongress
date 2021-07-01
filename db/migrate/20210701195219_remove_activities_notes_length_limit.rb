class RemoveActivitiesNotesLengthLimit < ActiveRecord::Migration[6.0]
  def change
    change_column :activities, :notes, :text
  end
end
