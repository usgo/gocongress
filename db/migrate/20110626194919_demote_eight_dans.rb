class DemoteEightDans < ActiveRecord::Migration
  def up
    Attendee.update_all 'rank = 7', 'rank > 7 and rank < 100'
  end

  def down
    raise IrreversibleMigration
  end
end
