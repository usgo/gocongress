class MinorAgreementValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, checkbox_value)
    unless checkbox_value || !record.birth_date || !record.minor?
      msg = " - Because this attendee will not be 18 years of age on the " \
        "first day of the Congress, you must agree to submit the Youth " \
        "Attendance Agreement to the registrar."
      record.errors[:liability_release] << msg
    end
  end
end
