class AddOrdinalToContents < ActiveRecord::Migration[5.2]
  def change
    add_column :contents, :ordinal, :integer, null: false, default: 1
  end
end
