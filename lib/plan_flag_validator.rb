class PlanFlagValidator < ActiveModel::EachValidator

  def validate_each(plan, attribute, value)

    # this validation only applies to plans in the roomboard categories
    if plan.plan_category.present? and plan.plan_category.show_on_roomboard_page?

      # such plans must have rooms or meals to be valid
      unless plan.has_meals || plan.has_rooms
        plan.errors[attribute] << (options[:message] || " - Plan must have rooms and/or meals")
      end
    end
  end

end
