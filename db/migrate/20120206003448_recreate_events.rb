class RecreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :year, :null => false
      t.string :name, :null => false
    end
  end
end
