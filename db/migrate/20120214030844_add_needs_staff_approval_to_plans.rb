class AddNeedsStaffApprovalToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :needs_staff_approval, :boolean, default: false, null: false
  end
end
