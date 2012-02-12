class AddMandatoryToPlanCategory < ActiveRecord::Migration
  def change
    add_column :plan_categories, :mandatory, :boolean, :null => false, :default => false
  end
end
