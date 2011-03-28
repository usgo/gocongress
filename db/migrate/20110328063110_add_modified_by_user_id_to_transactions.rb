class AddModifiedByUserIdToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :updated_by_user_id, :integer
  end

  def self.down
    remove_column :transactions, :updated_by_user_id
  end
end
