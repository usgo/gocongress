class Registration::Registration

  def initialize attendee, as_admin
    @attendee = attendee
    @as_admin = as_admin
  end

  # `register_activities` persists the selected activities
  def register_activities activity_id_array
    activity_registration_errors = []
    begin
      @attendee.replace_all_activities(activity_id_array)
    rescue DisabledActivityException
      activity_registration_errors << "Please do not add or remove disabled activities. Changes discarded."
    end
    return activity_registration_errors
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

    # Mandatory plan categories require at least one plan
    # if @plan_category.mandatory? && nascent_attendee_plans.empty?
    #  plan_registration_errors << "This is a mandatory category, so please select at
    #    least one #{Plan.model_name.human.downcase}."
    # end

    return plan_registration_errors
  end
end
