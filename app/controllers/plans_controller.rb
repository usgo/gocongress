class PlansController < ApplicationController
  include DollarController
  include YearlyController

  # Callbacks, in order
  add_filter_converting_param_to_cents :price
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

  def show
  end

  def new
    @plan_categories = categories_for_select
  end

  def edit
    @plan_categories = categories_for_select
  end

  def create
    @plan.year = @year.year
    @plan_categories = categories_for_select
    if @plan.save
      redirect_to plan_category_path(@plan.plan_category), :notice => 'Plan created.'
    else
      render :action => "new"
    end
  end

  def update
    @plan_categories = categories_for_select
    if @plan.update_attributes!(plan_params)
      redirect_to plan_category_path(@plan.plan_category), :notice => 'Plan updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    begin
      @plan.destroy
      flash[:notice] = "Plan deleted."
      redirect_to plan_category_path(@plan.plan_category)
    rescue ActiveRecord::DeleteRestrictionError => e
      @plan.errors.add(:base, e)
      flash[:alert] = "Cannot delete plan because attendees have already selected it."
      redirect_to plan_path(@plan)
    end
  end

  private

  def categories_for_select
    PlanCategory.yr(@year).order(:name).to_a.map {|c| [c.name, c.id]}
  end

  def plan_params
    params.require(:plan).permit(:cat_order, :daily, :name, :price, :age_min,
      :age_max, :description, :disabled, :show_disabled, :inventory,
      :max_quantity, :n_a, :needs_staff_approval, :plan_category_id)
  end
end
