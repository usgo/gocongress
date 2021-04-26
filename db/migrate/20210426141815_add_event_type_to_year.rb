class AddEventTypeToYear < ActiveRecord::Migration[5.0]
  def change
    add_column :years, :event_type, :integer, default: 'in-person'
    change_column_null :years, :city, true
    change_column_null :years, :state, true
  end
end
