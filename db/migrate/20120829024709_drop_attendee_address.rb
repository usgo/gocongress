class DropAttendeeAddress < ActiveRecord::Migration
  def up
    remove_column :attendees, :address_1, :address_2, :city, :state, :zip
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
