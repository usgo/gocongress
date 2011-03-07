class Discount < ActiveRecord::Base
  has_many :attendee_discounts, :dependent => :destroy
  has_many :attendees, :through => :attendee_discounts

  validates_presence_of :name, :amount
  validates_length_of :name, :maximum => 50
  validates_numericality_of :amount, :greater_than => 0
  validates_numericality_of :age_min, :only_integer => true, :allow_nil => true
  validates_numericality_of :age_max, :only_integer => true, :allow_nil => true
  validates_inclusion_of :is_automatic, :in => [true, false]

  def get_age_range_in_words
    returned_words = ""
    if age_min > 0 && age_max.blank?
      returned_words += age_min.to_s + " and older"
    elsif age_min == 0 && age_max.present? && age_max > 0
      returned_words += age_max.to_s + " and younger"
    elsif age_min > 0 && age_max.present? && age_max > 0
      returned_words += age_min.to_s + " to " + age_max.to_s
    end
    return returned_words
  end

  def get_invoice_item_name
    invoice_item_name = 'Discount: ' + name
    if age_min.present? || age_max.present? then
      invoice_item_name += ' (' + get_age_range_in_words + ')'
    end
    return invoice_item_name
  end

end
