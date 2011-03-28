class AddCheckNumberToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :check_number, :integer
  end

  def self.down
    remove_column :transactions, :check_number
  end
end
