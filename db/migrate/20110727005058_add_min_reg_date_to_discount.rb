class AddMinRegDateToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :min_reg_date, :date, :null => true
  end
end
