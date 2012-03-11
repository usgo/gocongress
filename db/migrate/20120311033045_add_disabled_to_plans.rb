class AddDisabledToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :disabled, :boolean, :null => false, :default => false
  end
end
