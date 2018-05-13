class AddNotificationMessageToRounds < ActiveRecord::Migration[5.0]
  def change
    add_column :rounds, :notification_message, :text
  end
end
