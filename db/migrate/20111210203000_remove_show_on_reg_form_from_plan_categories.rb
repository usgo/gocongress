class RemoveShowOnRegFormFromPlanCategories < ActiveRecord::Migration
  def up
    remove_column :plan_categories, :show_on_reg_form
  end

  def down
    raise IrreversibleMigration
  end
end
