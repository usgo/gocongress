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

  def transaction_to_array(t)
    a = []
    a << t.created_at.to_date
    a << t.get_trantype_name
    a << t.amount
    a << t.user.email
    a << t.gwtranid
    a << t.check_number
    a << (t.updated_by_user.present? ? t.updated_by_user.primary_attendee.given_name : nil)
    a << t.updated_at.to_date
    a << (t.gwdate.present? ? t.gwdate.to_date : nil)
    a << (t.comment.present? ? t.comment : nil)
    return a
  end

end
