class AddQuantityToAttendeePlan < ActiveRecord::Migration
  def self.up
    add_column :attendee_plans, :quantity, :integer, {:null => false, :default => 1}
  end

  def self.down
    remove_column :attendee_plans, :quantity
  end
end
