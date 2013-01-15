module AttendeeHelper

  def address_without_linebreaks(a)
    "#{a.address_1} #{a.address_2} #{a.city}, #{a.state} #{a.zip} #{a.country}"
  end

  def plan_selection_inputs plan
    selection = plan_selection(plan)
    if plan.daily?
      plan_date_fields(plan, selection)
    elsif plan.max_quantity == 1
      plan_cbx(plan, selection)
    else
      plan_qty_field(plan, selection)
    end
  end

  def plan_date_fields plan, selection
    render 'shared/plan_date_fields', :locals => {plan: plan, selection: selection}
  end

  def plan_cbx plan, selection
    checked = selection.qty == 1
    title = "Select this " + mnh
    check_box_tag qty_field_name(plan), 1, checked, :title => title
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

  private

  def mnh
    Plan.model_name.human.downcase
  end

  def plan_selection plan
    @plan_selections.select { |ps| ps.plan.id == plan.id }.first ||
      Registration::PlanSelection.new(plan, 0)
  end

  def qty_field_name plan
    "plan_#{plan.id}_qty"
  end

end
