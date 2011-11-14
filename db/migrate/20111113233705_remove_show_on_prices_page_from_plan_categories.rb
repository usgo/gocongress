class RemoveShowOnPricesPageFromPlanCategories < ActiveRecord::Migration
  def up
    remove_column :plan_categories, :show_on_prices_page
  end

  def down
    add_column :plan_categories, :show_on_prices_page, :boolean
  end
end
