class CreatePreregistrants < ActiveRecord::Migration
  def self.up
    create_table :preregistrants do |t|
      t.string :firstname, :null => false
      t.string :lastname, :null => false
      t.date :preregdate, :null => false
      t.string :ranktype, :null => false
      t.integer :rank, :null => false
      t.string :country, :null => false
      t.string :email, :null => false
      t.boolean :anonymous, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :preregistrants
  end
end
