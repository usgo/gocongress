class AddPriceVariesToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :price_varies, :boolean, null: false, default: false
    execute <<-SQL
      ALTER TABLE activities
        ADD CONSTRAINT ck_activities_price_varies
        CHECK (not price_varies or price = 0);
    SQL
  end
end
