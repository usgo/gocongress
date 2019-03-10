require 'action_view/helpers/translation_helper'

class Registration
  include ActiveModel::Model

  # Include `TranslationHelper` so that we can internationalize
  # validation error messages
  include ActionView::Helpers::TranslationHelper

  attr_reader :activity_selections, :attendee, :current_user,
    :plan_selections, :understand_minor

  # Use MinorAgreementValidator (found in lib/) to require that understand_minor
  # be checked if the attendee will not be 18 before the first day of the Congress.
  validates :understand_minor, :minor_agreement => true

  # `ATD_ATRS` is an array of *permitted* attendee attributes.
  # Forbidden attributes, like `year`, are omitted.
  ATD_ATRS = [:aga_id, :alternate_name, :anonymous,
    :birth_date, :country, :email, :emergency_name, :emergency_phone,
    :family_name, :gender, :given_name, :guardian_attendee_id,
    :guardian_full_name, :local_phone, :phone, :rank, :receive_sms, :roomate_request,
    :special_request, :shirt_id, :state, :tshirt_size, :understand_minor,
    :will_play_in_us_open, :comment, :minor_agreement_received]

  delegate(*ATD_ATRS, to: :attendee)
  delegate :full_name, :id, :minor?, :user_id, :year, to: :attendee
  delegate :admin?, to: :current_user

  def initialize current_user, attendee
    @current_user = current_user
    @attendee = attendee
    @errors = ActiveModel::Errors.new(self)
    @activity_selections = attendee.activity_ids
    @plan_selections = attendee.plan_selections
  end

  def activities
    Activity.yr(year).order(:leave_time, :name)
  end

  def guardian_name
    attendee.guardian.try(:full_name)
  end

  def show_availability
    Plan.inventoried_plan_in? form_plans
  end

  def show_quantity_instructions
    Plan.quantifiable_plan_in? form_plans
  end

  def submit params
    params[:activity_ids] ||= {}
    params[:plans] ||= {}
    params[:registration] ||= {}

    params.permit!
    p = params.to_h

    @activity_selections = p[:activity_ids].map(&:to_i)
    @plan_selections = parse_plan_params(p[:plans])
    @understand_minor = p[:registration][:understand_minor]
    attendee.attributes = attendee_params(p[:registration])

    valid? && save
  end

  def persisted?
    attendee.persisted?
  end

  # A registration is `valid?` if all of its parts are valid
  # and no `@errors` are found.
  def valid?
    super
    if attendee.valid?
      validate_mandatory_plan_cats(selected_plans)
      validate_single_plan_categories(selected_plans)
      validate_disabled_plans(persisted_plan_selections, selected_plans)
      validate_models(selected_attendee_plans)
      validate_activities
    else
      merge_errors(attendee.errors)
    end
    @errors.empty?
  end

  def plans_by_category
    form_plans.group_by(&:plan_category)
  end

  def attendee_number
    @attendee.user.attendees.count + 1
  end

  private

  def attendee_params(params)
    if not admin?
      # Remove admin-only permitted attributes
      atrs = ATD_ATRS - [:comment, :minor_agreement_received]
    else
      atrs = ATD_ATRS
    end

    atrs = atrs.concat(["birth_date(1i)", "birth_date(2i)", "birth_date(3i)", "user_id"])
    params.slice(*atrs)
  end

  # `all_plans` includes all disabled plans, whereas `form_plans` does not
  def all_plans
    Plan.joins(:plan_category).includes(:plan_category) \
      .yr(year).order('plan_categories.ordinal, plans.cat_order')
  end

  def convert_radio_btn_params params
    normalized_params = {}
    params.each do |key, value|
      if key.include?("single")
        plan_id_key = params[key]["plan_id"]
        normalized_params[plan_id_key] = { "qty"=>"1" }
      else
        normalized_params[key] = value
      end
    end
    normalized_params
  end

  # `form_plans` returns the plans to show on the form, and thus
  # excludes disabled plans unless already selected by the attendee or if
  # show_disabled is set to true.
  def form_plans
    return @_plans if @_plans.present?
    @_plans = all_plans.to_a
    unless admin?
      @_plans.delete_if {|p| p.disabled? && !@attendee.has_plan?(p) && !p.show_disabled?}
    end
    @_plans
  end

  def merge_errors e
    e.each { |atr, err| @errors.add(atr, err) }
  end

  def parse_plan_params plan_params
    converted_params = convert_radio_btn_params(plan_params)
    Registration::PlanSelection.parse_params(converted_params, all_plans)
  end

  def persist_plans
    @attendee.attendee_plans = selected_attendee_plans
    @attendee.attendee_plans.each do |ap|
      ap.dates.clear
      selected_dates(ap.plan).each do |date|
        ap.dates.create!(_date: date)
      end
    end
  end

  def save
    attendee.save!
    persist_activities
    persist_plans
    true
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

  def mandatory_plan_categories
    PlanCategory.yr(year).mandatory
  end

  def mandatory_plan_cat_error category
    pmnhd = Plan.model_name.human.downcase
    "Please select at least one #{pmnhd} in #{category.name}"
  end

  def persist_activities
    @attendee.activity_ids = @activity_selections
  end

  def persisted_plan_selections
    @attendee.attendee_plans.map do |ap|
      Registration::PlanSelection.new(ap.plan, ap.quantity)
    end
  end

  def selected_plan_categories plan_selections
    plan_selections.select{|s| s.qty > 0}.map(&:plan).map(&:plan_category)
  end

  def selected_plan_count(category, selections)
    selections.count {|s| s.plan.plan_category_id == category.id}
  end

  def single_plan_categories
    PlanCategory.yr(year).single
  end

  def single_plan_category_error category
    pmnhd = Plan.model_name.human.downcase
    "Please select exactly one #{pmnhd} in #{category.name}."
  end

  def unselected_mandatory_plan_cats plan_selections
    mandatory_plan_categories - selected_plan_categories(plan_selections)
  end

  def validate_activities
    changes = FindsChangesToDisabledActivities.new(@attendee.activity_ids, @activity_selections)
    unless admin? || changes.valid?
      @errors[:base] << translate('vldn_errs.activity_disabled')
    end
  end

  # `validate_disabled_plans` determines if any disabled plans
  # would be removed, added, or modified?  Admins are exempt from
  # this validation.
  def validate_disabled_plans before, after
    unless admin?
      changes = FindsChangesToDisabledPlans.new(before, after)
      @errors[:base].concat(changes.removal_errors)
      @errors[:base].concat(changes.addition_errors)
    end
  end

  def validate_mandatory_plan_cats selections
    unselected_mandatory_plan_cats(selections).each do |c|
      @errors[:base] << mandatory_plan_cat_error(c)
    end
  end

  def validate_models models
    models.reject(&:valid?).each do |m|
      m.errors.each do |atr, msg|
        @errors[:base] << "#{m.class}: #{atr}: #{msg}"
      end
    end
  end

  def validate_single_plan_categories selections
    single_plan_categories.each do |c|
      if selected_plan_count(c, selections) > 1
        @errors[:base] << single_plan_category_error(c)
      end
    end
  end
end
