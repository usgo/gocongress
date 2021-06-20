class AlterTransactions < ActiveRecord::Migration
  def self.up
    rename_column :transactions, :userid, :user_id

    # gwtimestamp -> gwdate
    rename_column :transactions, :gwtimestamp, :gwdate
    change_column :transactions, :gwdate, :date
  end

  def self.down
    rename_column :transactions, :user_id, :userid

    # gwdate -> gwtimestamp
    rename_column :transactions, :gwdate, :gwtimestamp
    change_column :transactions, :gwtimestamp, :timestamp
  end
end
