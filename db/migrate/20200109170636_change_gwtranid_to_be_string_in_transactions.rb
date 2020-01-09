class ChangeGwtranidToBeStringInTransactions < ActiveRecord::Migration[5.0]
  def self.up
    change_column :transactions, :gwtranid, :string
  end

  def self.down
    change_column :transactions, :gwtranid, :integer
  end
end
