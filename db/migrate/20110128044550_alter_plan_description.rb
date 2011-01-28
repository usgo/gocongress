class AlterPlanDescription < ActiveRecord::Migration
  def self.up
    remove_column :plans, :description
    add_column :plans, :description, :text
  end

  def self.down
    remove_column :plans, :description
    add_column :plans, :description, :string
  end
end
