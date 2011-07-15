class AddInstrumentToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :instrument, :string, :limit => 1
  end
end
