class AttendeePlan < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :plan

  # attr_accessible is not necessary, because
  # there is no AttendeePlan controller

  validates :year, :numericality => { :only_integer => true, :greater_than => 2010, :less_than => 2100 }
  validates_presence_of :attendee, :plan

  validates_numericality_of :quantity, \
    :only_integer => true, \
    :greater_than_or_equal_to => 1

  # Instead of using less_than_or_equal_to, we use a block so
  # that we can provide a meaningful message. -Jared
  validates_each :quantity do |model, attr, value|
    max_qty = model.plan.max_quantity
    if value > max_qty then
      model.errors.add(attr.to_s.titleize, ' of ' + model.plan.name + ' must be less than or equal to ' + max_qty.to_s)
    end
  end

  before_validation do |ap|
    if ap.plan.year != ap.attendee.year
      raise "Attendee and Plan have different years"
    end
    ap.year ||= ap.attendee.year
  end

end
