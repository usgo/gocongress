class InvoiceItem

  def self.inv_item_hash( item_description, attendee_full_name, item_price, qty )
    item = {}
    item['item_description'] = item_description
    item['attendee_full_name'] = attendee_full_name
    item['item_price'] = Float(item_price)
    item['qty'] = qty
    return item
  end

end
