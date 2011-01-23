class CreatePlans < ActiveRecord::Migration
  def self.up
    create_table :plans do |t|
      t.string :name          , :null => false, :limit => 50
      t.string :description   , :limit => 250
      t.decimal :price        , :null => false, :precision => 10, :scale => 2
      t.integer :age_min      , :null => false
      t.integer :age_max

      t.timestamps
    end
  end

  def self.down
    drop_table :plans
  end
end
