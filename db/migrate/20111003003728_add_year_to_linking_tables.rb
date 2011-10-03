class AddYearToLinkingTables < ActiveRecord::Migration
  def up
    add_column :user_jobs, :year, :integer
    execute <<-SQL      
      update user_jobs uj
      set year = u.year
      from users u
      where u.id = uj.user_id;
    SQL
    change_column :user_jobs, :year, :integer, :null => false

    add_column :attendee_events, :year, :integer
    execute <<-SQL      
      update attendee_events ae
      set year = a.year
      from attendees a
      where a.id = ae.attendee_id;
    SQL
    change_column :attendee_events, :year, :integer, :null => false

    add_column :attendee_plans, :year, :integer
    execute <<-SQL      
      update attendee_plans ap
      set year = a.year
      from attendees a
      where a.id = ap.attendee_id;
    SQL
    change_column :attendee_plans, :year, :integer, :null => false

    add_column :attendee_tournaments, :year, :integer
    execute <<-SQL      
      update attendee_tournaments at
      set year = a.year
      from attendees a
      where a.id = at.attendee_id;
    SQL
    change_column :attendee_tournaments, :year, :integer, :null => false

    add_column :attendee_discounts, :year, :integer
    execute <<-SQL      
      update attendee_discounts ad
      set year = a.year
      from attendees a
      where a.id = ad.attendee_id;
    SQL
    change_column :attendee_discounts, :year, :integer, :null => false
  end
end
