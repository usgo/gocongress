class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :userid,				:null => false
      t.string :trantype,				:null => false, :limit => 1
      t.decimal :amount,				:null => false, :scale => 2, :precision => 10
      t.integer :gwtranid,			:null => false
      t.timestamp :gwtimestamp, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
