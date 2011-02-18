class PlanFlagValidator < ActiveModel::EachValidator
  def validate_each(plan, attribute, value)
    unless plan.has_meals || plan.has_rooms
      plan.errors[attribute] << (options[:message] || " - Plan must have rooms and/or meals")
    end
  end
end
