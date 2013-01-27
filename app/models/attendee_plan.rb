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

  validates_each :dates do |model, atr, value|
    if model.plan.present? && !model.plan.daily? && !value.empty?
      model.errors.add(atr, translate('vldn_errs.plan_forbids_dates'))
    end
  end

  validates :quantity,
    :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}

  validates_each :quantity do |model, atr, value|
    model.validate_against_max_quantity
    model.validate_against_available_inventory
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

  def to_plan_selection
    Registration::PlanSelection.new plan, quantity, dates.map(&:_date)
  end

  # Quantity may not exceed available inventory
  def validate_against_available_inventory
    i = inventory_available_to_this_attendee
    if i.present? && quantity > i then
      errors[:base] << "#{plan.name.pluralize}: You requested #{quantity}, but there are only #{i} available."
    end
  end

  # Quantity may not exceed max_quantity (per attendee)
  def validate_against_max_quantity
    max_qty = plan.max_quantity
    if quantity > max_qty then
      errors[:base] << "The maximum quantity of #{plan.name.pluralize.downcase} per attendee is #{max_qty}"
    end
  end

  # Private instance methods
  # ------------------------

  private

  def inventory_available_to_this_attendee
    plan.inventory_available(attendee)
  end

end
