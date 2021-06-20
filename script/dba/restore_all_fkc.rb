# This is a hacky fix to an ugly situation I find myself in.  I used
# heroku db:pull a few times and now I don't have any FKCs.  Heroku's
# tap gem does not support FKCs, so a pull ignores them.  My local
# development and my staging site lack them.  Thankfully, I never used
# db:push on production, or I would have lost them there too.
#
# So, I needed a way to restore FKCs.  I couldn't use migrations,
# because if one query fails (eg. an FKC already exists) then the whole
# migration transaction is cancelled and all further commands in that
# migration are ignored.
#
# So, invoke this from inside the rails console
# require "#{Rails.root}/script/dba/restore_all_fkc.rb"
# RestoreAllFKC.restore_all
#

require "postgres_migration_helpers"

module PostgresMigrationHelpers
  def execute(query)
    ActiveRecord::Base.connection.execute(query)
  end
end

class RestoreAllFKC
  extend PostgresMigrationHelpers

  def self.restore_all
    try_restore { add_pg_foreign_key :user_jobs, [:job_id, :year], :jobs, [:id, :year] }
    try_restore { add_pg_foreign_key :user_jobs, [:user_id, :year], :users, [:id, :year] }
    try_restore { add_pg_foreign_key :transactions, [:user_id, :year], :users, [:id, :year], 'restrict' }
    try_restore { add_pg_foreign_key :transactions, [:updated_by_user_id, :year], :users, [:id, :year], 'set null', 'simple' }
    try_restore { add_pg_foreign_key :activities, [:activity_category_id, :year], :activity_categories, [:id, :year] }
    try_restore { add_pg_foreign_key :attendees, [:user_id, :year], :users, [:id, :year] }
    try_restore { add_pg_foreign_key :attendee_activities, [:attendee_id, :year], :attendees, [:id, :year] }
    try_restore { add_pg_foreign_key :attendee_activities, [:activity_id, :year], :activities, [:id, :year] }
    try_restore { add_pg_foreign_key :attendee_plans, [:attendee_id, :year], :attendees, [:id, :year] }
    try_restore { add_pg_foreign_key :attendee_plans, [:plan_id, :year], :plans, [:id, :year], 'restrict' }
    try_restore { add_pg_foreign_key :attendee_tournaments, [:attendee_id, :year], :attendees, [:id, :year] }
    try_restore { add_pg_foreign_key :attendee_tournaments, [:tournament_id, :year], :tournaments, [:id, :year] }
    try_restore { add_pg_foreign_key :plans, [:plan_category_id, :year], :plan_categories, [:id, :year] }
    try_restore { add_pg_foreign_key :contents, [:content_category_id, :year], :content_categories, [:id, :year] }
    try_restore { add_pg_foreign_key :plan_categories, [:event_id, :year], :events, [:id, :year] }
  end

  private

  def self.try_restore
    begin
      yield
    rescue StandardError => e
      puts e.inspect
    end
  end
end
