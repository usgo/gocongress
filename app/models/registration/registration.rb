require 'action_view/helpers/translation_helper'

class Registration::Registration
  include SplitDatetimeParser

  # Include `TranslationHelper` so that we can internationalize
  # validation error messages
  include ActionView::Helpers::TranslationHelper

  def initialize attendee, as_admin, params, plan_selections
    @as_admin = as_admin
    @attendee = attendee
    @params = params
    @plan_selections = plan_selections
    @year = attendee.year
  end

  def save
    errors = []

    # Assign airport_arrival and airport_departure attributes, if possible
    errors += parse_airport_datetimes

    if @attendee.new_record?
      # Activities haven't been validated yet, so we unset them
      # before `save`. (they had been set by cancan)
      @attendee.activities = []
      @attendee.save
    end

    unless @attendee.new_record?

      # Regular users are not allowed to add or remove disabled activities.
      errors += validate_activities @params[:activity_ids]

      # Persist discounts, activities, and plans
      register_discounts(discount_ids)
      errors += register_plans(@plan_selections)

      set_admin_params
      delete_protected_params

      if errors.empty?
        @attendee.update_attributes(@params)
      end
    end

    return errors
  end

  # `validate_activities` checks that the `selected` activity ids
  # are not adding or removing a disabled activity.  Admins are
  # exempt from this validation.
  def validate_activities selected
    return [] if @as_admin
    before = @attendee.activities.map(&:id)
    after = Set.new selected.map(&:to_i)
    changes = (after ^ before).to_a
    invalids = disabled_activities & changes
    return invalids.empty? ? [] : [translate(:activity_disabled_msg)]
  end

  # `register_discounts` persists claimed (non-automatic) discounts
  def register_discounts selected_discount_ids
    available_discounts = Discount.yr(@attendee.year).automatic(false)
    @attendee.discounts = available_discounts.where('id in (?)', selected_discount_ids)
  end

  # `register_plans` persists the selected plans, replacing
  # all existing `AttendeePlan` records.
  def register_plans plan_selections
    plan_registration_errors = []
    nascent_attendee_plans = []

    # Mandatory plan categories require at least one plan
    unselected_mandatory_plan_categories(plan_selections).each do |c|
      plan_registration_errors << mandatory_plan_category_error(c)
    end

    plan_selections.each do |plan_selection|
      p = plan_selection.plan
      qty = plan_selection.qty
      if qty == 0

        # Only admins can remove previously selected disabled plans
        if p.disabled? && @attendee.has_plan?(p) && !@as_admin
          plan_registration_errors << "It looks like you're trying to remove a
            disabled plan (#{p.name}).  Please contact the registrar
            for help"
          ap_copy = @attendee.attendee_plans.where(plan_id: p.id).first.dup
          nascent_attendee_plans << ap_copy
        end

      elsif qty > 0
        ap = AttendeePlan.new(:attendee_id => @attendee.id, :plan_id => p.id, :quantity => qty)
        if ap.valid?

          # Only admins can add new disabled plans that weren't
          # previously selected
          if p.disabled? && !@attendee.has_plan?(p) && !@as_admin
            plan_registration_errors << "One of the plans you selected (#{ap.plan.name})
              is disabled. You cannot selected disabled plans.  In fact,
              you shouldn't have even been able to see it.  Please contact
              the registrar for help."
          else
            nascent_attendee_plans << ap
          end
        else
          plan_registration_errors.concat ap.errors.map {|k,v| k.to_s + " " + v.to_s}
        end
      end
    end

    @attendee.clear_plans!

    unless nascent_attendee_plans.empty?
      @attendee.attendee_plans << nascent_attendee_plans
    end

    return plan_registration_errors
  end

  private

  def clear_airport_datetime_params
    %w(airport_arrival airport_departure).each do |prefix|
      %w(date time).each do |suffix|
        @params.delete(prefix + '_' + suffix)
      end
    end
  end

  def delete_protected_params
    [:comment, :discount_ids, :minor_agreement_received].each do |p|
      @params.delete p
    end
  end

  def disabled_activities
    @disabled_activities ||= Activity.disabled.map(&:id)
  end

  # `discount_ids` returns positive integer ids, ignoring
  # unchecked boxes in the view
  def discount_ids
    ids = @params[:discount_ids] || []
    ids.delete_if {|d| d.to_i == 0}
  end

  def mandatory_plan_categories
    PlanCategory.yr(@year).mandatory
  end

  def mandatory_plan_category_error category
    pmnhd = Plan.model_name.human.downcase
    "Please select at least one #{pmnhd} in #{category.name}"
  end

  def parse_airport_datetimes
    parse_errors = []
    begin
      @attendee.airport_arrival = parse_split_datetime(@params, :airport_arrival)
      @attendee.airport_departure = parse_split_datetime(@params, :airport_departure)
    rescue SplitDatetimeParserException => e
      parse_errors << e.to_s
    end
    clear_airport_datetime_params
    return parse_errors
  end

  def selected_plan_categories plan_selections
    plan_selections.select{|s| s.qty > 0}.map(&:plan).map(&:plan_category)
  end

  def set_admin_params
    if @as_admin
      [:comment, :minor_agreement_received].each do |p|
        unless @params[p].nil?
          @attendee[p] = @params[p]
        end
      end
    end
  end

  def unselected_mandatory_plan_categories plan_selections
    mandatory_plan_categories - selected_plan_categories(plan_selections)
  end

end
