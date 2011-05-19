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

  def attendee_to_array(a)
    ar = []

    # basic attendee attributes
    a.attribute_names_for_csv.each do |attr|
      if a[attr].blank?
        ar << nil
      else
        if attr == 'rank'
          ar << a.get_rank_name
        elsif attr == 'tshirt_size'
          ar << a.get_tshirt_size_name
        else
          ar << a[attr]
        end
      end
    end

    # basic user attributes
    %w[email].each do |attr|
      if a.user.blank? || a.user[attr].blank?
        ar << nil
      else
        ar << a.user[attr]
      end
    end

    # claimed discounts
    claimed_discount_ids = a.discounts.where('is_automatic = ?', false).map { |d| d.id }
    claimable_discounts = Discount.where('is_automatic = ?', false).order(:name)
    claimable_discounts.each do |d|
      ar << claimed_discount_ids.index(d.id).present? ? 'yes' : 'no'
    end

    # plans
    plan_ids = a.plans.map { |p| p.id }
    Plan.order(:name).each do |p|
      ar << plan_ids.index(p.id).present? ? 'yes' : 'no'
    end

    return ar
  end

end
