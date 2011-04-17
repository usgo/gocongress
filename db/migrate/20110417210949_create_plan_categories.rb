class CreatePlanCategories < ActiveRecord::Migration
  def self.up
    create_table :plan_categories do |t|
      t.string :name, :null => false
      t.boolean :show_on_prices_page, :null => false
      t.boolean :show_on_roomboard_page, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :plan_categories
  end
end
