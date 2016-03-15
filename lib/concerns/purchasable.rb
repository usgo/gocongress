# A model is `purchasable` if it has a `price` and attendees
# can select it and pay for it.
module Purchasable

  # http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
  extend ActiveSupport::Concern

  included do
    validates :price, :numericality => {
      allow_nil: false,
      greater_than_or_equal_to: 0,
      only_integer: true
    }

    # Admin cannot change the price if attendees have already selected it
    validates_each :price do |record, attr, value|
      if record.price_changed? && !record.attendees.empty?
        record.errors.add(attr, price_change_err_msg(record))
      end
    end
  end

  def price_for_display
    if self.respond_to?(:price_varies?) && price_varies?
      "Varies"
    elsif contact_msg_instead_of_price?
      "Contact the Registrar"
    elsif self.respond_to?(:n_a) && n_a? && price.to_f == 0.0
      "N/A"
    elsif price.to_f == 0.0
      "Free"
    else
      ApplicationController.helpers.cents_to_currency(price) + price_units
    end
  end

  def price_units
    (respond_to?(:daily) && daily?) ? ' / day' : ''
  end

  def contact_msg_instead_of_price?
    self.respond_to?(:needs_staff_approval) && needs_staff_approval?
  end

  module ClassMethods
    def price_change_err_msg record
      record_model_name = record.class.model_name.human.downcase
      attendee_model_name = Attendee.model_name.human.downcase
      basic_msg = " may not change, because at least one #{attendee_model_name}
        has already selected this #{record_model_name}."
      suggestion = record.respond_to?(:disabled) ? " If you do not want
        anyone else to select this #{record_model_name} at this price,
        you may disable this #{record_model_name}." : ""
      return basic_msg + suggestion
    end
  end

end
