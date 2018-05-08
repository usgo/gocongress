class AddRefundPolicyToYear < ActiveRecord::Migration[5.0]
  def change
    add_column :years, :refund_policy, :text
  end
end
