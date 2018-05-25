module AttendeeHelper

  def plan_selection_inputs plan
    selection = plan_selection(plan)
    if plan.daily?
      plan_date_fields(plan, selection)
    elsif plan.max_quantity == 1
      plan.plan_category.single === true ? plan_radio_btn(plan, selection) : plan_cbx(plan, selection)
    else
      plan_qty_field(plan, selection)
    end
  end

  def plan_date_fields plan, selection
    render :partial => 'shared/plan_date_fields',
      :locals => {plan: plan, selection: selection}
  end

  def plan_cbx plan, selection
    checked = selection.qty == 1
    title = "Select this " + mnh
    if plan.disabled? && !current_user_is_admin?
      check_box_tag qty_field_name(plan), 1, checked, :disabled => true
    else
      check_box_tag qty_field_name(plan), 1, checked, :title => title
    end
  end

  def plan_radio_btn(plan, selection)
    checked = selection.qty === 1
    title = "Select this " + mnh
    if plan.disabled? && !current_user_is_admin?
      radio_button_tag radio_btn_name(plan), plan.id, checked, :disabled => true
    else
      radio_button_tag radio_btn_name(plan), plan.id, checked, :title => title
    end
  end

  def plan_qty_field plan, selection
    number_field_tag(
      qty_field_name(plan),
      selection.qty,
      :size => 2,
      :min => 0,
      :max => plan.max_quantity,
      :title => "Enter a quantity"
    )
  end

  def plan_label_name plan
    if plan.max_quantity == 1
      plan.plan_category.single === true ?
        "plans_single_plan_cat_id:#{plan.plan_category.id}_plan_id_#{plan.id}" :
        qty_field_name(plan)
    end
  end

  private

  def mnh
    Plan.model_name.human.downcase
  end

  def plan_selection plan
    @registration.plan_selections.select { |ps| ps.plan.id == plan.id }.first ||
      Registration::PlanSelection.new(plan, 0)
  end

  # Return selected plan for a given plan category
  def plan_category_selection category
    @registration.plan_selections.select { |ps| ps.plan.plan_category_id == category.id }
  end

  def qty_field_name plan
    "plans[#{plan.id}][qty]"
  end

  def radio_btn_name plan
    "plans[single_plan_cat_id:#{plan.plan_category.id}][plan_id]"
  end

end
