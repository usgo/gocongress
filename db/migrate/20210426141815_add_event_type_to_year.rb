class AddEventTypeToYear < ActiveRecord::Migration[5.0]
  def change
    add_column :years, :event_type, :integer, default: 'in-person'
  end
end
