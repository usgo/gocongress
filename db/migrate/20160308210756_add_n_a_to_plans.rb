class AddNAToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :n_a, :boolean, :null => false, :default => false
  end
end
