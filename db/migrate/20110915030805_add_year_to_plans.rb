class AddYearToPlans < ActiveRecord::Migration
  def up
    add_column :plans, :year, :integer
    add_column :plan_categories, :year, :integer
    Plan.update_all :year => 2011
    PlanCategory.update_all :year => 2011
    change_column :plans, :year, :integer, :null => false
    change_column :plan_categories, :year, :integer, :null => false
  end
  
  def down
    remove_column :plan, :year
    remove_column :plan_categories, :year
  end
end
