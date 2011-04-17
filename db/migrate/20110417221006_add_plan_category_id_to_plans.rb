class AddPlanCategoryIdToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :plan_category_id, :integer
  end

  def self.down
    remove_column :plans, :plan_category_id
  end
end
