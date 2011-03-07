class AlterDiscountsDropNotNullOnAgeMin < ActiveRecord::Migration
  def self.up
    change_column :discounts, :age_min, :integer, :null => true
  end

  def self.down
    change_column :discounts, :age_min, :integer, :null => false
  end
end
