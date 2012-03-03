class UpdateTimesToUtc < ActiveRecord::Migration

  # The current times in the database are saved in local time.
  # We currently perform no translation for display purposes.
  # However, we will begin translating for display, so we need
  # to fix the times in the database.
  def up
    update_times :+
  end

  def down
    update_times :-
  end

  private

  def update_times operator
    # 2011 times need to have seven hours added (PDT)
    # 2012 times need four hours added (EDT)
    ts_cols.each do |table, cols|
      cols.each do |col|
        model_class = table.to_s.singularize.camelize.constantize
        model_class.send :update_all, "#{col} = #{col} #{operator} interval '7 hours'", {:year => 2011}
        model_class.send :update_all, "#{col} = #{col} #{operator} interval '4 hours'", {:year => 2012}
      end
    end

    # The stupid razamfrazm rounds table has no year column
    [:created_at, :updated_at, :round_start].each do |col|
      Round.joins(:tournament).update_all "#{col} = #{col} #{operator} interval '7 hours'", "tournaments.year = 2011"
      Round.joins(:tournament).update_all "#{col} = #{col} #{operator} interval '4 hours'", "tournaments.year = 2012"
    end
  end

  def ts_cols
    caua = [:created_at, :updated_at]
    return {
      jobs: caua,
      user_jobs: caua,
      transactions: caua,
      users: caua.clone.concat([:remember_created_at, :current_sign_in_at, :last_sign_in_at]),
      contents: caua.clone.concat([:expires_at]),
      attendee_tournaments: caua,
      attendee_discounts: caua,
      attendees: caua,
      attendee_activities: caua,
      attendee_plans: caua,
      plan_categories: caua,
      discounts: caua,
      # rounds: caua.clone.concat([:round_start]),
      plans: caua,
      tournaments: caua,
      activities: caua.clone.concat([:leave_time]),
      content_categories: caua
    }
  end
end

# The following is a list of all timestamp columns in the database
#
# select relname, attname, t.typname as attr_type
# from pg_attribute a
# inner join pg_class r on r.oid = a.attrelid
# inner join pg_type t on a.atttypid = t.oid
# where r.relnamespace = 2200 -- public namespace
#   and r.reltype <> 0 -- exclude indexes
#   and t.typname = 'timestamp'
#
#
#        relname        |       attname       | attr_type
# ----------------------+---------------------+-----------
#  jobs                 | created_at          | timestamp
#  jobs                 | updated_at          | timestamp
#  user_jobs            | created_at          | timestamp
#  user_jobs            | updated_at          | timestamp
#  transactions         | created_at          | timestamp
#  transactions         | updated_at          | timestamp
#  users                | remember_created_at | timestamp
#  users                | current_sign_in_at  | timestamp
#  users                | last_sign_in_at     | timestamp
#  users                | created_at          | timestamp
#  users                | updated_at          | timestamp
#  contents             | expires_at          | timestamp
#  contents             | created_at          | timestamp
#  contents             | updated_at          | timestamp
#  attendee_tournaments | created_at          | timestamp
#  attendee_tournaments | updated_at          | timestamp
#  attendee_discounts   | created_at          | timestamp
#  attendee_discounts   | updated_at          | timestamp
#  attendees            | created_at          | timestamp
#  attendees            | updated_at          | timestamp
#  attendee_activities  | created_at          | timestamp
#  attendee_activities  | updated_at          | timestamp
#  attendee_plans       | created_at          | timestamp
#  attendee_plans       | updated_at          | timestamp
#  plan_categories      | created_at          | timestamp
#  plan_categories      | updated_at          | timestamp
#  discounts            | created_at          | timestamp
#  discounts            | updated_at          | timestamp
#  rounds               | round_start         | timestamp
#  rounds               | created_at          | timestamp
#  rounds               | updated_at          | timestamp
#  plans                | created_at          | timestamp
#  plans                | updated_at          | timestamp
#  tournaments          | created_at          | timestamp
#  tournaments          | updated_at          | timestamp
#  activities           | leave_time          | timestamp
#  activities           | created_at          | timestamp
#  activities           | updated_at          | timestamp
#  content_categories   | created_at          | timestamp
#  content_categories   | updated_at          | timestamp
#

