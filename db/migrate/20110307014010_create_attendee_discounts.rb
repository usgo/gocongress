class CreateAttendeeDiscounts < ActiveRecord::Migration
  def self.up
    create_table :attendee_discounts do |t|
      t.integer :attendee_id, :null => false
      t.integer :discount_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :attendee_discounts
  end
end
