class PlanCategoriesController < ApplicationController
  include YearlyController

  # Callbacks, in order
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route
  before_action :events_for_select, :only => [:create, :edit, :new, :update]
  before_action :max_description_length, :only => [:create, :edit, :new, :update]
  before_action :expose_plans, :only => [:show, :update]

  def index
    if @year.year != 2019 || current_user_is_admin?
      categories = @plan_categories.joins(:event).yr(@year).order('ordinal')
      @plan_categories_by_event = categories \
        .select("plan_categories.*, events.name as event_name") \
        .group_by {|c| c.event_name}
      @show_order_fields = can?(:update, PlanCategory) && categories.count > 1
    else
      redirect_to year_path
    end
  end

  def show
    @show_availability = Plan.inventoried_plan_in? @plans
  end

  def create
    if @plan_category.save
      redirect_to(@plan_category, :notice => 'Plan category created.')
    else
      render :action => "new"
    end
  end

  def update

    if params[:commit] == 'Update Order'
      @plan_category.reorder_plans(params[:plan_order])
    else
      unless @plan_category.update_attributes!(plan_category_params)
        render :action => "edit" and return
      end
    end

    # We were successful, regardless of what we did :-)
    redirect_to(@plan_category, :notice => 'Plan category updated.')
  end

  def update_order
    (params[:ordinals] || {}).each do |id, ord|
      PlanCategory.yr(@year).find(id).update_attributes!(:ordinal => ord)
    end
    redirect_to plan_categories_path, :notice => 'Order updated.'
  end

  def destroy
    begin
      @plan_category.destroy
      flash[:notice] = 'Category deleted.'
    rescue ActiveRecord::DeleteRestrictionError
      flash[:alert] = "Cannot delete the '#{@plan_category.name}' category
        because its plans have already been selected by attendees."
    end
    redirect_to plan_categories_url
  end

  private

  def max_description_length
    @max_description_length = PlanCategory.validators_on( :description ).first.options[:maximum]
  end

  def events_for_select
    @events_for_select = Event.yr(@year).alphabetical.to_a.map {|e| [e.name, e.id]}
  end

  def expose_plans
    visible_plans = @plan_category.plans.accessible_by(current_ability, :show)
    @plans = visible_plans.order('cat_order')
    @show_order_fields = can?(:update, Plan) && @plans.count > 1
  end

  def plan_category_params
    params.require(:plan_category).permit(:extended_description, :description, :event_id, :mandatory,
      :name, :ordinal, :show_description, :single)
  end
end
