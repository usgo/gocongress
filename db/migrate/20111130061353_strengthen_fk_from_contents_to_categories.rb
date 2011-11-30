require "postgres_migration_helpers"

class StrengthenFkFromContentsToCategories < ActiveRecord::Migration
  include PostgresMigrationHelpers
  
  def up
    # remove the "weak" FK ..
    remove_pg_foreign_key :contents, [:content_category_id]
    
    # .. and replace it with a "stronger" FK that includes year
    # (postgres requires an explicit unique index)
    add_index :content_categories, [:id, :year], :unique => true
    add_pg_foreign_key :contents, [:content_category_id, :year], :content_categories, [:id, :year]
  end

  def down
    add_pg_foreign_key :contents, [:content_category_id], :content_categories, [:id]
    remove_pg_foreign_key :contents, [:content_category_id, :year]
  end
end
