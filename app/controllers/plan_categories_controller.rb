class PlanCategoriesController < ApplicationController

  load_and_authorize_resource
  before_filter :events_for_select, :only => [:create, :edit, :new, :update]

  def index
    categories = @plan_categories \
      .select("plan_categories.*, events.name as event_name") \
      .yr(@year).joins(:event).order("events.name, plan_categories.name")
    @plan_categories_by_event = categories.group_by {|c| c.event_name}
  end

  def show
    @plans = @plan_category.plans.alphabetical
    @show_availability = Plan.show_availability?(@plans)
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
    if @plan_category.update_attributes(params[:plan_category])
      redirect_to(@plan_category, :notice => 'Plan category updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @plan_category.destroy
    redirect_to plan_categories_url
  end

  private

  def events_for_select
    @events_for_select = Event.yr(@year).alphabetical.all.map {|e| [e.name, e.id]}
  end

end
