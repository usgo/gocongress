class AlterTransactionsMakeGwdateNullable < ActiveRecord::Migration
  def self.up
    change_column :transactions, :gwdate, :date, :null => true
  end

  def self.down
    change_column :transactions, :gwdate, :date, :null => false
  end
end
