class CreateAttendeePlans < ActiveRecord::Migration
  def self.up
    create_table :attendee_plans do |t|
      t.integer :attendee_id,   :null => false
      t.integer :plan_id,       :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :attendee_plans
  end
end
