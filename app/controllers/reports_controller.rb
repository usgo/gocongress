class ReportsController < ApplicationController

  # Access Control
  before_filter :allow_only_admin

  def index
  end

  def emails
    @atnd_email_list = ""
    Attendee.all.each { |a|
      @atnd_email_list += "\"#{a.get_full_name}\" <#{a.email}>, "
      }
  end

  def overdue_deposits
    @overdue_users = []
    User.all.each { |u|
      is_deposit_paid = u.get_num_attendee_deposits_paid == u.attendees.count
      is_past_deposit_due_date = u.get_initial_deposit_due_date < Time.now.to_date
      if (is_past_deposit_due_date && !is_deposit_paid) then
        @overdue_users << u
      end
    }
  end

end
