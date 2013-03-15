require "postgres_migration_helpers"

class CreateTshirtColor < ActiveRecord::Migration
  include PostgresMigrationHelpers

  def up
    create_table :shirt_colors do |t|
      t.integer :year,        :null => false
      t.string :name,         :null => false, :limit => 30
      t.string :hex_triplet,  :null => false, :limit => 6
    end
    add_index :shirt_colors, [:name, :year], :unique => true
    add_index :shirt_colors, [:hex_triplet, :year], :unique => true

    add_column :attendees, :shirt_color_id, :integer
    add_index :shirt_colors, [:id, :year], :unique => true
    add_pg_foreign_key \
      :attendees, [:shirt_color_id, :year],
      :shirt_colors, [:id, :year],
      'restrict', 'simple'
  end

  def down
    remove_pg_foreign_key :attendees, [:shirt_color_id, :year]
    remove_column :attendees, :shirt_color_id
    drop_table :shirt_colors
  end
end
