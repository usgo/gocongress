module Purchasable

  # http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
  extend ActiveSupport::Concern

  included do
    validates :price, :numericality => { greater_than_or_equal_to: 0, allow_nil: false }
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
