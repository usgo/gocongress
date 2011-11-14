class RemoveShowOnRoomboardPageFromPlanCategories < ActiveRecord::Migration
  def up
    remove_column :plan_categories, :show_on_roomboard_page
  end

  def down
    add_column :plan_categories, :show_on_roomboard_page, :boolean
  end
end
