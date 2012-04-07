class RegistrationProcess
  include Rails.application.routes.url_helpers

  def initialize attendee
    @attendee = attendee
  end

  def after_sign_in_path
    @attendee.has_plans? ? my_account_path : next_page(:basics, nil, [])
  end

  # `next_page` returns the path to the next "page", usually in the
  # registration process.
  def next_page(current_page, plan_category, events_of_interest)
    raise ArgumentError if (current_page.nil? && plan_category.nil?)
    Attendee.assert_valid_page(current_page) if plan_category.nil?

    # Coming from the first page (basics) go to the events page
    if current_page.to_s == "basics"
      return page_path :events
    end

    # Coming from the second page (events) go to the first
    # appropriate plan category, if there is one.
    if current_page.to_s == "events"
      cat = PlanCategory.first_reg_form_category(@attendee.year, @attendee, events_of_interest)
      return cat.present? ? plan_category_path(cat) : page_path(:wishes)
    end

    # Coming from the final page, we always go to the "My Account" page next
    if current_page.to_s == "wishes"
      return my_account_path
    end

    # If we're coming from one plan category, go to the next.
    # If this is the last category, go to :wishes.
    if plan_category.present?
      cat = plan_category.next_reg_form_category(@attendee, events_of_interest)
      return cat.present? ? plan_category_path(cat) : page_path(:wishes)
    end

    # By default, return to the "My Account" page
    return my_account_path
  end

private

  def my_account_path
    user_path(@attendee.year, @attendee.user)
  end

  def page_path(page)
    edit_attendee_path(@attendee.year, @attendee, page.to_sym)
  end

  # TODO: misleading method name
  def plan_category_path(plan_category)
    edit_plans_for_attendee_path(@attendee.year, @attendee, plan_category)
  end

end
