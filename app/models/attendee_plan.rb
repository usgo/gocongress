require 'action_view/helpers/translation_helper'

class AttendeePlan < ActiveRecord::Base
  include YearlyModel
  extend ActionView::Helpers::TranslationHelper

  belongs_to :attendee
  belongs_to :plan
  has_many :dates, :class_name => 'AttendeePlanDate'

  # As with other attendee linking tables, mass-assignment security
  # is not necessary yet, but may be in the future.  See the more
  # detailed discussion in `attendee_activity.rb` -Jared 2012-07-15
  attr_accessible :attendee_id, :plan_id, :quantity

  # Validations
  # -----------

  validates_presence_of :attendee, :plan

  validates_numericality_of :quantity, \
    :only_integer => true, \
    :greater_than_or_equal_to => 1

  validates_each :dates do |model, atr, value|
    if model.plan.present? && model.plan.daily_rate.blank? && !value.empty?
      model.errors.add(atr, translate('vldn_errs.plan_forbids_dates'))
    end
  end

  # Validate quantity with respect to max_quantity and inventory.
  validates_each :quantity do |model, atr, value|
    plan_name = model.plan.name.pluralize

    # Quantity may not exceed max_quantity
    max_qty = model.plan.max_quantity
    if value > max_qty then
      model.errors[:base] << "The maximum #{atr.to_s.downcase} of #{plan_name.downcase} per attendee is #{max_qty}"
    end

    # What is the available inventory for this plan, excluding the
    # current attendee who may be trying to increase their quantity?
    available = model.plan.inventory_available(model.attendee)

    # Quantity may not exceed available inventory
    if available.present? && value > available then
      model.errors[:base] << "#{plan_name}: You requested #{value}, but there are only #{available} available."
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

  # Optimization: Avoid a query by passing
  # `attendee_full_name` as an argument
  def to_invoice_item attendee_full_name
    InvoiceItem.new('Plan: ' + plan.name, attendee_full_name, plan.price, quantity)
  end

end
