class AddNnConstraintOnPlanCategoryId < ActiveRecord::Migration
  def up
    change_column :plans, :plan_category_id, :integer, :null => false
  end

  def down
    change_column :plans, :plan_category_id, :integer, :null => true
  end
end
