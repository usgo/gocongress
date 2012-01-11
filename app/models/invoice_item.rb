class InvoiceItem
  attr_reader :description, :attendee_full_name, :price, :qty

  def initialize(description, attendee_full_name, price, qty)
    @description = description.to_s
    @attendee_full_name = attendee_full_name.to_s
    @price = price.to_f
    @qty = qty.to_i
  end
end
