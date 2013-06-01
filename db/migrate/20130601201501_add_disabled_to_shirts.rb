class AddDisabledToShirts < ActiveRecord::Migration
  def change
    add_column :shirts, :disabled, :boolean, null: false, default: false
  end
end
