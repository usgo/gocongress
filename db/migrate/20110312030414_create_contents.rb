class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.text :body, :null => false
      t.string :subject, :null => false
      t.timestamp :expires_at
      t.boolean :show_on_homepage, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :contents
  end
end
