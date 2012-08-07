class AddDisabledToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :disabled, :boolean,
      {null: false, default: false}
  end
end
