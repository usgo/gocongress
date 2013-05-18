class AttendeesCsvExporter

  # It is convenient for name and email to be in the first few
  # columns, and for roommate request to be next to the plans.
  # Order must match `attendee_to_array`.
  def self.attendee_attribute_names
    first_attrs = %w[aga_id family_name given_name country phone]
    last_attrs = %w[special_request roomate_request]
    attrs = Attendee.attribute_names.reject { |x|
      first_attrs.index(x) ||
      last_attrs.index(x) ||
      Attendee.internal_attributes.index(x)
    }
    return first_attrs.concat(attrs.concat(last_attrs))
  end

  # Order of columns must match `header_line`
  def self.attendee_to_array(a)
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
    attendee_attribute_names.each do |atr|
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

  # Order must match `attendee_to_array`
  def self.header_line year
    plans = Plan.yr(year).order(:name).map{ |p| "Plan: " + safe_for_csv(p.name)}
    (['user_email'] + attendee_attribute_names + ['shirt_style'] + plans).join(',')
  end

  def self.safe_for_csv(str)
    str.tr(',"', '')
  end

end
