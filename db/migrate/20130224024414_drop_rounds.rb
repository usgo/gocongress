class DropRounds < ActiveRecord::Migration
  def up
    drop_table :rounds
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
