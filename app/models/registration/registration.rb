class Registration::Registration

  def initialize attendee, as_admin
    @attendee = attendee
    @year = attendee.year
    @as_admin = as_admin
  end

  def validate_activities value
    raise "Expected enumerable" unless value.respond_to?(:each)
    selected = value.map(&:to_i)
    raise "Found something non-numeric in value" if selected.include?(nil)
    errors = []
    before = AttendeeActivity.where(:attendee_id => @attendee.id).map(&:activity_id)
    disableds = Activity.disabled.map(&:id)
    adding = selected - before
    unless (adding & disableds).empty?
      errors << activity_disabled_message('add')
    end
    removing = before - selected
    unless (removing & disableds).empty?
      errors << activity_disabled_message('remove')
    end
    return errors
  end

  # `register_discounts` persists claimed (non-automatic) discounts
  def register_discounts discount_ids
    available_discounts = Discount.yr(@attendee.year).automatic(false)
    @attendee.discounts = available_discounts.where('id in (?)', discount_ids)
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

  def activity_disabled_message verb
    "- One of the activities you tried to #{verb} has been disabled.
    Please contact the registrar for help."
  end


  def mandatory_plan_categories
    PlanCategory.yr(@year).mandatory
  end

  def mandatory_plan_category_error category
    pmnhd = Plan.model_name.human.downcase
    "Please select at least one #{pmnhd} in #{category.name}"
  end

  def selected_plan_categories plan_selections
    plan_selections.select{|s| s.qty > 0}.map(&:plan).map(&:plan_category)
  end

  def unselected_mandatory_plan_categories plan_selections
    mandatory_plan_categories - selected_plan_categories(plan_selections)
  end

end
