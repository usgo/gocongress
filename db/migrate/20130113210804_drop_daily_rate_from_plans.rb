class DropDailyRateFromPlans < ActiveRecord::Migration
  def up
    remove_column :plans, :daily_rate
    add_column :plans, :daily, :boolean, :null => false, :default => false
  end

  def down
    add_column :plans, :daily_rate, :integer, :null => true
    remove_column :plans, :daily
  end
end
