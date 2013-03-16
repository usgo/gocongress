require "postgres_migration_helpers"

class RenameShirt < ActiveRecord::Migration
  include PostgresMigrationHelpers

  def up
    remove_pg_foreign_key :attendees, [:shirt_color_id, :year]
    remove_column :attendees, :shirt_color_id
    drop_table :shirt_colors

    create_table :shirts do |t|
      t.integer :year,        :null => false
      t.string :name,         :null => false, :limit => 40
      t.string :hex_triplet,  :null => false, :limit => 6
      t.string :description,  :null => false, :limit => 100
      t.string :image_url,                    :limit => 250
      t.timestamps
    end
    add_index :shirts, [:name, :year], :unique => true
    add_index :shirts, [:hex_triplet, :year], :unique => true

    add_column :attendees, :shirt_id, :integer
    add_index :shirts, [:id, :year], :unique => true
    add_pg_foreign_key \
      :attendees, [:shirt_id, :year],
      :shirts, [:id, :year],
      'restrict', 'simple'
  end

  def down
    raise IrreversibleMigration # Just lazy
  end
end
