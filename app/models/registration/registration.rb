require 'action_view/helpers/translation_helper'

class Registration::Registration
  include SplitDatetimeParser

  # Include `TranslationHelper` so that we can internationalize
  # validation error messages
  include ActionView::Helpers::TranslationHelper

  def initialize attendee, as_admin, params, plan_selections, activity_selections
    @as_admin = as_admin
    @attendee = attendee
    @params = params
    @params[:attendee] ||= {} # in case of lazy tests
    @plan_selections = plan_selections
    @activity_selections = activity_selections.map(&:to_i)
    @year = attendee.year
  end

  def save
    errors = parse_airport_datetimes
    @attendee.save if @attendee.new_record?

    unless @attendee.new_record?
      errors += register_activities
      errors += register_plans
      errors += update_attendee_attributes
    end

    return errors
  end

  # `register_plans` validates and persists the selected plans
  # with positive quantities.  If any validations fail, no
  # selections will be persisted.
  def register_plans
    ers = []
    ers += validate_mandatory_plan_cats(selected_plans)
    ers += validate_disabled_plans(persisted_plan_selections, selected_plans)
    ers += validate_models(selected_attendee_plans)
    persist_plans if ers.empty?
    return ers
  end

  private

  def persist_plans
    @attendee.attendee_plans = selected_attendee_plans
    @attendee.attendee_plans.each do |ap|
      ap.dates.clear
      selected_dates(ap.plan).each do |date|
        ap.dates.create!(_date: date)
      end
    end
  end

  def selected_dates plan
    ps = @plan_selections.find {|s| s.plan.id == plan.id}
    ps.nil? ? [] : ps.dates
  end

  def selected_attendee_plans
    selected_plans.map { |s| s.to_attendee_plan(@attendee) }
  end

  def selected_plans
    @plan_selections.select { |s| s.qty > 0 }
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

  # `parse_airport_datetimes` assigns airport_arrival and
  # airport_departure attributes, if possible
  def parse_airport_datetimes
    parse_errors = []
    begin
      @attendee.airport_arrival = parse_split_datetime(@params, :airport_arrival)
      @attendee.airport_departure = parse_split_datetime(@params, :airport_departure)
    rescue SplitDatetimeParserException => e
      parse_errors << e.to_s
    end
    return parse_errors
  end

  def persist_activities
    @attendee.activity_ids = @activity_selections
  end

  def persisted_plan_selections
    @attendee.attendee_plans.map do |ap|
      Registration::PlanSelection.new(ap.plan, ap.quantity)
    end
  end

  def register_activities
    errors = validate_activities
    persist_activities if errors.empty?
    return errors
  end

  def selected_plan_categories plan_selections
    plan_selections.select{|s| s.qty > 0}.map(&:plan).map(&:plan_category)
  end

  def update_attendee_attributes
    begin
      @attendee.update_attributes(@params[:attendee], :as => mass_assignment_role)
    rescue ActiveModel::MassAssignmentSecurity::Error => e
      return ["Permission denied: #{e}"]
    end
    return []
  end

  def unselected_mandatory_plan_cats plan_selections
    mandatory_plan_categories - selected_plan_categories(plan_selections)
  end

  # `changes_to_selected_activities`, ie. the symmetric
  # difference (http://bit.ly/aNXT8U) of "before" and "after" sets
  def changes_to_selected_activities
    Set.new(@activity_selections) ^ @attendee.activity_ids
  end

  # Adding or removing disabled activities are invalid changes
  def invalid_changes_to_selected_activities
    changes_to_selected_activities & disabled_activities
  end

  def activities_are_valid?
    @as_admin || invalid_changes_to_selected_activities.empty?
  end

  def validate_activities
    activities_are_valid? ? [] : [translate('vldn_errs.activity_disabled')]
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

  def validate_mandatory_plan_cats selections
    unselected_mandatory_plan_cats(selections).map{|c| mandatory_plan_cat_error(c)}
  end

  def validate_models models
    models.reject(&:valid?).map{|m| m.errors.full_messages}.flatten
  end

end
