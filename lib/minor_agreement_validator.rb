class MinorAgreementValidator < ActiveModel::EachValidator
  AGE_DEADLINE = "July 29, 2011"

  def validate_each(user, attribute, checkbox_value)
    deadline = Date.strptime(AGE_DEADLINE, "%B %d, %Y")

    unless checkbox_value || !user.birth_date || (user.birth_date + 18.years < deadline)
      user.errors[attribute] << (options[:message] || " - Because this attendee will not be 18 years of age on or before #{AGE_DEADLINE}, you must agree to submit the Minor Agreement Form to the deputy registrar.")
    end
  end
end
