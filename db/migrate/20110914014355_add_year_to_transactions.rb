class AddYearToTransactions < ActiveRecord::Migration
  def up
    add_column :transactions, :year, :integer
    Transaction.update_all :year => 2011
    change_column :transactions, :year, :integer, :null => false
  end
  
  def down
    remove_column :transactions, :year
  end
end
