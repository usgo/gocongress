class AttendeesExporter

  # Lisa wants the name and email in the first few columns.
  # We want roommate request next to the plans.
  # The order must match attendee_to_array() in reports_helper.rb
  def self.attendee_attribute_names_for_csv
    first_attrs = %w[aga_id family_name given_name country phone]
    last_attrs = %w[special_request roomate_request]
    attrs = Attendee.attribute_names.reject { |x|
      first_attrs.index(x) ||
      last_attrs.index(x) ||
      Attendee.internal_attributes.index(x)
    }
    return first_attrs.concat(attrs.concat(last_attrs))
  end

  # The order of `csv_header_line` must match
  # `attendee_to_array` in `reports_helper.rb`
  def self.csv_header_line year
    atrs = AttendeesExporter.attendee_attribute_names_for_csv
    plans = Plan.yr(year).order(:name).map{ |p| "Plan: " + safe_for_csv(p.name)}
    (['user_email'] + atrs + ['shirt_style'] + plans).join(',')
  end

end
