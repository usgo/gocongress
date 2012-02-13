class MakeActivitiesPriceRequired < ActiveRecord::Migration
  def up
    execute "update activities set price = 0.0 where price is null"
    change_column :activities, :price, :decimal,
      :precision => 10, :scale => 2, :null => false
  end

  def down
    change_column :activities, :price, :decimal,
      :precision => 10, :scale => 2, :null => true
  end
end
