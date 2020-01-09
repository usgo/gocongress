class AddReceiptUrlToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :receipt_url, :string
  end
end
