class AddCompoundUniqueConstraintsToLinkingTables < ActiveRecord::Migration
  def self.up
    add_index :attendee_discounts, \
      [:attendee_id, :discount_id], \
      { :name => :uniq_attendee_discount, :unique => true }

    add_index :attendee_plans, \
      [:attendee_id, :plan_id], \
      { :name => :uniq_attendee_plan, :unique => true }

    add_index :user_jobs, \
      [:user_id, :job_id], \
      { :name => :uniq_user_job, :unique => true }
  end

  def self.down
    remove_index :attendee_discounts, :name => :uniq_attendee_discount
    remove_index :attendee_plans, :name => :uniq_attendee_plan
    remove_index :user_jobs, :name => :uniq_user_job
  end
end
