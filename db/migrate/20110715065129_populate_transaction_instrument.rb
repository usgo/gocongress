class PopulateTransactionInstrument < ActiveRecord::Migration
  def up
    # all refunds to date have been paid with checks
    execute "update transactions set instrument = 'K' where trantype = 'R'"

    # all sales to date have been paid with cards
    execute "update transactions set instrument = 'C' where trantype = 'S'"
  end

  def down
    raise IrreversibleMigration
  end
end
