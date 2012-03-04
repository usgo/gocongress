# A model is `purchasable` if it has a `price` and attendees
# can select it and pay for it.
module Purchasable

  # http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
  extend ActiveSupport::Concern

  included do
    validates :price, :numericality => { greater_than_or_equal_to: 0, allow_nil: false }

    # Admin cannot change the price if attendees have already selected it
    validates_each :price do |record, attr, value|
      if record.price_changed? && !record.attendees.empty?
        record.errors.add(attr, " may not change, because at least one
          #{Attendee.model_name.human.downcase} has already selected
          this #{record.class.model_name.human.downcase}")
      end
    end
  end

  def price_for_display
    if contact_msg_instead_of_price?
      "Contact the Registrar"
    elsif price.to_f == 0.0
      "Free"
    else
      ActionController::Base.helpers.number_to_currency(price, :precision => 2)
    end
  end

  def contact_msg_instead_of_price?
    self.respond_to?(:needs_staff_approval) && needs_staff_approval?
  end

end
