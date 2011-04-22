class AddCommentToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :comment, :string
  end

  def self.down
    remove_column :transactions, :comment
  end
end
