class AttendeePlan < ActiveRecord::Base
  include YearlyModel
  belongs_to :attendee
  belongs_to :plan

  # attr_accessible is not necessary, because
  # there is no AttendeePlan controller

  validates_presence_of :attendee, :plan

  validates_numericality_of :quantity, \
    :only_integer => true, \
    :greater_than_or_equal_to => 1

  # Validate quantity with respect to max_quantity and inventory.
  validates_each :quantity do |model, attr, value|
    plan_name = model.plan.name.pluralize.downcase

    # Quantity may not exceed max_quantity
    max_qty = model.plan.max_quantity
    if value > max_qty then
      model.errors.add("The maximum #{attr.to_s.downcase} of #{plan_name} per attendee",
        " is #{max_qty}")
    end

    # What is the available inventory for this plan, excluding the
    # current attendee who may be trying to increase their quantity?
    available = model.plan.inventory_available(model.attendee)

    # Quantity may not exceed available inventory
    if available.present? && value > available then
      model.errors.add("#{model.plan.name.pluralize}:",
        "You requested #{value}, but there are only #{available} available.")
    end
  end

  before_validation do |ap|
    if ap.plan.present? && ap.attendee.present?
      if ap.plan.year != ap.attendee.year
        raise "Attendee and Plan have different years"
      end
      ap.year ||= ap.attendee.year
    end
  end

  # Public instance methods
  # -----------------------

  def show_on_invoice?
    ! plan.needs_staff_approval?
  end

  def to_invoice_item
    InvoiceItem.new('Plan: ' + plan.name, attendee.full_name, plan.price, quantity)
  end

end
