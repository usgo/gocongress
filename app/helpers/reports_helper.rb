module ReportsHelper

  def transaction_to_array(t)
    a = []
    a << t.created_at.to_date
    a << t.get_trantype_name
    a << t.amount
    a << t.user.email
    a << t.user.full_name
    a << t.gwtranid
    a << t.check_number
    a << (t.updated_by_user.present? ? t.updated_by_user.primary_attendee.given_name : nil)
    a << t.updated_at.to_date
    a << (t.gwdate.present? ? t.gwdate.to_date : nil)
    a << (t.comment.present? ? html_escape(t.comment) : nil)
    return a
  end

  # The order of columns in `attendee_to_array` must match the order
  # of `csv_header_line` in the `attendee_reports_controller`
  def attendee_to_array(a)
    ar = []

    # basic user attributes
    %w[email].each do |attr|
      if a.user.blank? || a.user[attr].blank?
        ar << nil
      else
        ar << a.user[attr]
      end
    end

    # basic attendee attributes
    Attendee.attribute_names_for_csv.each do |atr|
      ar << a.attribute_value_for_csv(atr)
    end

    # lisa says: plans should come right after attendee attrs
    pqh = a.plan_qty_hash
    Plan.yr(a.year).order(:name).each do |p|
      plan_qty = pqh[p.id].present? ? pqh[p.id].to_i : 0
      ar << plan_qty.to_i
    end

    # claimed discounts
    claimed_discount_ids = a.discounts.automatic(false).map { |d| d.id }
    claimable_discounts = Discount.for_report(a.year)
    claimable_discounts.each do |d|
      ar << claimed_discount_ids.index(d.id).present? ? 'yes' : 'no'
    end

    return ar
  end

end
