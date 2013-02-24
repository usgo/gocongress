class AlterTransactionsAlterGwtranid < ActiveRecord::Migration
  def up
    # It's bizzare, but `:limit => 8` actually means "8 bytes"
    change_column :transactions, :gwtranid, :integer, :limit => 8
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
