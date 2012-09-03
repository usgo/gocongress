class DropAttendeeTournaments < ActiveRecord::Migration
  def up
    drop_table :attendee_tournaments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
