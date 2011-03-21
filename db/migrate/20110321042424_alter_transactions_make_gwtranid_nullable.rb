class AlterTransactionsMakeGwtranidNullable < ActiveRecord::Migration
  def self.up
    change_column :transactions, :gwtranid, :integer, :null => true
  end

  def self.down
    change_column :transactions, :gwtranid, :integer, :null => false
  end
end
