class ChangeDefaultValueForYearEventType < ActiveRecord::Migration[6.0]
  def change
    change_column_default :years, :event_type, from: 'in-person', to: 'in_person'
  end
end
