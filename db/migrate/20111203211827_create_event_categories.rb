require 'postgres_migration_helpers'

class CreateEventCategories < ActiveRecord::Migration
  include PostgresMigrationHelpers

  def up
    create_table :event_categories do |t|
      t.string :name, :null => false, :limit => 25
      t.integer :year, :null => false
    end
    change_table :events do |t|
      t.belongs_to :event_category
    end

    # In 2011, all events belonged to a single category
    ec = EventCategory.create!(name: "Events and Activities", year: 2011)
    Event.update_all({ event_category_id: ec.id }, { year: 2011 })

    # In 2012, go-related events and non-go activities will
    # be separate categories.  For now, put all the events in
    # the former category.  We'll move them later.
    ec_events = EventCategory.create!(name: "Events", year: 2012)
    ec_activities = EventCategory.create!(name: "Activities", year: 2012)
    Event.update_all({ event_category_id: ec_events.id }, { year: 2012 })

    # index for performance
    add_index :events, :event_category_id

    # index required by foreign key
    add_index :event_categories, [:id, :year], :unique => true
    add_pg_foreign_key :events, [:event_category_id, :year], :event_categories, [:id, :year]
  end

  def down
    remove_pg_foreign_key :events, [:event_category_id, :year]
    remove_index :events, :event_category_id
    remove_index :event_categories, [:id, :year]
    remove_column :events, :event_category_id
    drop_table :event_categories
  end
end
