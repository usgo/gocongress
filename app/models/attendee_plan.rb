require 'action_view/helpers/translation_helper'

class AttendeePlan < ApplicationRecord
  include YearlyModel
  extend ActionView::Helpers::TranslationHelper

  belongs_to :attendee
  belongs_to :plan
  has_many :dates, :class_name => 'AttendeePlanDate'

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
    model.validate_against_min_age
    model.validate_against_max_age
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

  def invoice_plan_dates
    s = ' ('
    plan_dates.each do |d|
      unless d == plan_dates.last
        s += d + ', '
      else
        s += d
      end
    end
    s += ')'
  end

  def invoiced_quantity
    plan.daily? ? dates.length : quantity
  end

  def plan_dates
    dates.map {|d| d._date.strftime("%-m/%-d") }
  end

  def show_on_invoice?
    ! plan.needs_staff_approval?
  end

  # Optimization: Avoid a query by passing
  # `attendee_full_name` as an argument
  def to_invoice_item attendee_full_name, attendee_alternate_name
    if plan.daily?
      InvoiceItem.new(plan.name + invoice_plan_dates, attendee_full_name + attendee_alternate_name, plan.price, invoiced_quantity)
    else
      InvoiceItem.new(plan.name, attendee_full_name + attendee_alternate_name, plan.price, invoiced_quantity)
    end
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

  # Attendee age must be appropriate
  def validate_against_min_age
    age = attendee.age_in_years
    min = plan.age_min
    if age < min
      errors[:base] << "#{plan.name.pluralize}: Attendee age will be #{age} which is less than minimum age for this plan."
    end
  end

  def validate_against_max_age
    age = attendee.age_in_years
    max = plan.age_max
    if max.present? && age > max
      errors[:base] << "#{plan.name.pluralize}: Attendee age will be #{age} which is greater than maximum age for this plan."
    end
  end

  # Private instance methods
  # ------------------------

  private

  def inventory_available_to_this_attendee
    plan.inventory_available(attendee)
  end

end
