class PlansController < ApplicationController

  load_and_authorize_resource
  skip_authorize_resource :only => [:room_and_board,:prices_and_extras]

  # GET /plans
  def index
    plans_ordered = @plans.yr(@year).order "plan_category_id, name"
    @plans_grouped = plans_ordered.group_by {|plan| plan.plan_category_id}
  end

  # GET /plans/1
  def show
  end

  # GET /plans/new
  def new
    @plan_categories = get_plan_categories_for_select
  end

  # GET /plans/1/edit
  def edit
    @plan_categories = get_plan_categories_for_select
  end

  # POST /plans
  def create
    @plan.year = @year
    @plan_categories = get_plan_categories_for_select
    if @plan.save
      redirect_to plans_path, :notice => 'Plan created.'
    else
      render :action => "new"
    end
  end

  # PUT /plans/1
  def update
    @plan_categories = get_plan_categories_for_select
    if @plan.update_attributes(params[:plan])
      redirect_to plans_path, :notice => 'Plan updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /plans/1
  def destroy
    @plan.destroy
    redirect_to plans_url
  end

protected

  def page_title
    %w[room_and_board prices_and_extras].index(action_name).present? ? human_action_name : super
  end

private

  def get_plan_categories_for_select
    PlanCategory.yr(@year).all.map {|c| [c.name, c.id]}
  end

end
