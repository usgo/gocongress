class MinorAgreementValidator < ActiveModel::EachValidator

  def validate_each(attendee, attribute, checkbox_value)
    unless checkbox_value || !attendee.birth_date || !attendee.minor?
      msg = " - Because this attendee will not be 18 years of age on the first day of the Congress, you must agree to submit the Minor Agreement Form to the deputy registrar."
      attendee.errors[attribute] << (options[:message] || msg)
    end
  end
end
