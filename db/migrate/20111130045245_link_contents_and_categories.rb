require "postgres_migration_helpers"

class LinkContentsAndCategories < ActiveRecord::Migration
  include PostgresMigrationHelpers

  def up
    # All existing content items need categories ..
    add_column :contents, :content_category_id, :integer

    # .. so let's make an Announcements category for 2011
    # and a FAQ category for 2012 ..
    ann = ContentCategory.create!( year: 2011, name: 'Announcements' )
    faq = ContentCategory.create!( year: 2012, name: 'FAQ' )

    # .. assign content to their categories ..
    Content.update_all "content_category_id = #{ann.id}", "year = 2011"
    Content.update_all "content_category_id = #{faq.id}", "year = 2012"

    # .. now all content should have a category, so we add
    # a not null constraint and a foreign key
    change_column :contents, :content_category_id, :integer, null: false
    add_pg_foreign_key :contents, [:content_category_id], :content_categories, [:id]

    # .. and an index for performance
    add_index :contents, :content_category_id
  end

  def down
    remove_pg_foreign_key :contents, [:content_category_id]
    remove_index :contents, :content_category_id
    remove_column :contents, :content_category_id
  end
end
