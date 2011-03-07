class CreateDiscounts < ActiveRecord::Migration
  def self.up
    create_table :discounts do |t|
      t.string :name, :limit => 50, :null => false
      t.decimal :amount, :null => false
      t.integer :age_min, :null => false
      t.integer :age_max
      t.boolean :is_automatic, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :discounts
  end
end
