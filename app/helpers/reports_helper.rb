module ReportsHelper

  def transaction_to_array(t)
    a = []
    a << t.created_at.to_date
    a << t.get_trantype_name
    a << t.amount.to_f / 100
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
    AttendeesExporter.attendee_attribute_names_for_csv.each do |atr|
      ar << a.attribute_value_for_csv(atr)
    end

    # shirt name (tshirt style)
    ar << a.shirt.try('name')

    # lisa says: plans should come right after attendee attrs
    pqh = a.plan_qty_hash
    Plan.yr(a.year).order(:name).each do |p|
      plan_qty = pqh[p.id].present? ? pqh[p.id].to_i : 0
      ar << plan_qty.to_i
    end

    return ar
  end

end
