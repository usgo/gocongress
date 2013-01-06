class AddDailyRateToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :daily_rate, :integer, :null => true
  end
end
