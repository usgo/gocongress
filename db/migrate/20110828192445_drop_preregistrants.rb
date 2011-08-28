class DropPreregistrants < ActiveRecord::Migration
  def up
    drop_table :preregistrants
  end

  def down
    raise IrreversibleMigration
  end
end
