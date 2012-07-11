require "postgres_migration_helpers"

class CreateContacts < ActiveRecord::Migration
  include PostgresMigrationHelpers

  def up
    create_table :contacts do |t|
      t.integer :year,      :null => false
      t.string :title,      :null => false,   :limit => 50
      t.string :given_name, :null => false,   :limit => 50
      t.string :family_name, :null => false,  :limit => 50
      t.string :email,                        :limit => 100
      t.string :phone,                        :limit => 20
      t.integer :list_order
      t.timestamps
    end

    add_pg_foreign_key :contacts, [:year], :years, [:year]
  end

  def down
    drop_table :contacts
  end
end
