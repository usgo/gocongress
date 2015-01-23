class AddShowDisabledToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :show_disabled, :boolean, :null => false, :default => false
  end
end
