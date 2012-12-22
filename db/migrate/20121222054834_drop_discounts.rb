class DropDiscounts < ActiveRecord::Migration
  def up
    drop_table :attendee_discounts
    drop_table :discounts
  end

  def down
    raise IrreversibleMigration
  end
end
