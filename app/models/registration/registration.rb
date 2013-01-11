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

      # Persist plans
      errors += register_plans(@plan_selections)

      if errors.empty?
        begin
          @attendee.update_attributes(@params, :as => mass_assignment_role)
        rescue ActiveModel::MassAssignmentSecurity::Error => e
          errors << "Permission denied: #{e}"
        end
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
    return invalids.empty? ? [] : [translate('vldn_errs.activity_disabled')]
  end

  # `register_plans` validates and persists the selected plans
  # with positive quantities.  If any validations fail, no
  # selections will be persisted.
  def register_plans selections
    ers = []
    selections.select! {|s| s.qty > 0}
    nascent_attendee_plans = selections.map { |s| s.to_attendee_plan(@attendee) }
    ers += validate_mandatory_plan_cats(selections)
    ers += validate_disabled_plans(persisted_plan_selections, selections)
    ers += validate_models(nascent_attendee_plans)
    @attendee.attendee_plans = nascent_attendee_plans if ers.empty?
    return ers
  end

  private

  def clear_airport_datetime_params
    %w(airport_arrival airport_departure).each do |prefix|
      %w(date time).each do |suffix|
        @params.delete(prefix + '_' + suffix)
      end
    end
  end

  def validate_models models
    models.reject(&:valid?).map{|m| m.errors.full_messages}.flatten
  end

  def disabled_activities
    @disabled_activities ||= Activity.disabled.map(&:id)
  end

  def mandatory_plan_categories
    PlanCategory.yr(@year).mandatory
  end

  def mandatory_plan_cat_error category
    pmnhd = Plan.model_name.human.downcase
    "Please select at least one #{pmnhd} in #{category.name}"
  end

  def mass_assignment_role
    @as_admin ? :admin : :default
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

  def persisted_plan_selections
    @attendee.attendee_plans.map do |ap|
      Registration::PlanSelection.new(ap.plan, ap.quantity)
    end
  end

  def selected_plan_categories plan_selections
    plan_selections.select{|s| s.qty > 0}.map(&:plan).map(&:plan_category)
  end

  def unselected_mandatory_plan_cats plan_selections
    mandatory_plan_categories - selected_plan_categories(plan_selections)
  end

  def validate_mandatory_plan_cats selections
    unselected_mandatory_plan_cats(selections).map{|c| mandatory_plan_cat_error(c)}
  end

  # `validate_disabled_plans` determines if any disabled plans
  # would be removed, added, or modified?  Admins are exempt from
  # this validation.
  def validate_disabled_plans before, after
    errs = []
    unless @as_admin
      changes = Set.new(before) ^ after
      if changes.any? {|ap| ap.plan.disabled? }
        errs << "One of the plans you're trying to add or remove has
          been disabled.  Please contact the registrar for help."
      end
    end
    return errs
  end

end
