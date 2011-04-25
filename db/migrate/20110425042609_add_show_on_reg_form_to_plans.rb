class AddShowOnRegFormToPlans < ActiveRecord::Migration
  def self.up
    add_column :plan_categories, :show_on_reg_form, :boolean
  end

  def self.down
    remove_column :plan_categories, :show_on_reg_form
  end
end
