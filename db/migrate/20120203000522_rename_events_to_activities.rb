class RenameEventsToActivities < ActiveRecord::Migration
  def change

    # tables
    rename_table :event_categories, :activity_categories
    rename_table :events, :activities
    rename_table :attendee_events, :attendee_activities

    # columns
    rename_column :activities, :event_category_id, :activity_category_id
    rename_column :attendee_activities, :event_id, :activity_id

    # rename indexes in what used to be the events table
    rename_index :activities,
      :index_events_on_event_category_id,
      :index_activities_on_activity_category_id
    rename_index :activities,
      :index_events_on_id_and_year,
      :uniq_activities_on_id_and_year
    rename_index :activities,
      :index_events_on_year_and_start,
      :index_activities_on_year_and_start

    # rename indexes in what used to be the event_categories table
    rename_index :activity_categories,
      :index_event_categories_on_id_and_year,
      :uniq_activity_categories_on_id_and_year

    # rename indexes in what used to be the attendee_events table
    rename_index :attendee_activities,
      :uniq_attendee_event,
      :uniq_attendee_activity
    rename_index :attendee_activities,
      :index_attendee_events_on_event_id,
      :index_attendee_activities_on_activity_id
  end
end
