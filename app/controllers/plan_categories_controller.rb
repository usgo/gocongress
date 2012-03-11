class PlanCategoriesController < ApplicationController

  load_and_authorize_resource
  before_filter :events_for_select, :only => [:create, :edit, :new, :update]
  before_filter :expose_plans, :only => [:show, :update]

  def index
    categories = @plan_categories \
      .select("plan_categories.*, events.name as event_name") \
      .yr(@year).joins(:event).order("events.name, plan_categories.name")
    @plan_categories_by_event = categories.group_by {|c| c.event_name}
  end

  def show
    @show_availability = Plan.inventoried_plan_in? @plans
  end

  def create
    @plan_category.year = @year
    if @plan_category.save
      redirect_to(@plan_category, :notice => 'Plan category created.')
    else
      render :action => "new"
    end
  end

  def update
    if params[:plan_order].present?
      ordering = params[:plan_order].map{|x| x.to_i}
      unless @plan_category.reorder_plans(@plans, ordering)
        render :action => "show" and return
      end
    else
      unless @plan_category.update_attributes(params[:plan_category])
        render :action => "edit" and return
      end
    end

    # We were successful, regardless of what we did :-)
    redirect_to(@plan_category, :notice => 'Plan category updated.')
  end

  def destroy
    @plan_category.destroy
    redirect_to plan_categories_url
  end

  private

  def events_for_select
    @events_for_select = Event.yr(@year).alphabetical.all.map {|e| [e.name, e.id]}
  end

  def expose_plans
    visible_plans = @plan_category.plans.accessible_by(current_ability, :show)
    @plans = visible_plans.rank :cat_order
    @show_order_fields = can?(:update, Plan) && @plans.count > 1
  end

end
