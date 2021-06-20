class AddYearToDiscounts < ActiveRecord::Migration
  def up
    add_column :discounts, :year, :integer
    Discount.update_all :year => 2011
    change_column :discounts, :year, :integer, :null => false
  end

  def down
    remove_column :discounts, :year
  end
end
