module ReportsHelper

  def overdue_user_to_array(user)
    a = []
    a << user.email
    a << user.primary_attendee.get_full_name
    a << user.created_at.to_date.to_formatted_s
    a << user.get_initial_deposit_due_date.to_formatted_s
    a << user.attendees.count
    a << user.attendees.where('deposit_received_at is not null').length
    return a
  end

end
