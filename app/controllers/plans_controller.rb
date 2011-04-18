class PlansController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:room_and_board,:prices_and_extras]

  # GET /plans
  def index
    plans_ordered = Plan.all :order=>"plan_category_id, name"
    @plans_grouped = plans_ordered.group_by {|plan| plan.plan_category_id}
  end

  # GET /plans/room_and_board
  def room_and_board
    plans_ordered = Plan.room_and_board_page.order("has_rooms desc, age_min asc")
    @plans_grouped = plans_ordered.group_by {|plan| plan.has_rooms}
  end

  # GET /plans/prices_and_extras
  def prices_and_extras
    plans_ordered = Plan.prices_page.order("plan_category_id, name")
    @plans_grouped = plans_ordered.group_by {|plan| plan.plan_category_id}
  end

  # GET /plans/1
  def show
    @plan = Plan.find(params[:id])
  end

  # GET /plans/new
  def new
    @plan = Plan.new
    @plan_categories = get_plan_categories_for_select
  end

  # GET /plans/1/edit
  def edit
    @plan = Plan.find(params[:id])
    @plan_categories = get_plan_categories_for_select
  end

  # POST /plans
  def create
    @plan = Plan.new(params[:plan])
    @plan_categories = get_plan_categories_for_select
    if @plan.save
      redirect_to plans_path, :notice => 'Plan was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /plans/1
  def update
    @plan = Plan.find(params[:id])
    @plan_categories = get_plan_categories_for_select
    if @plan.update_attributes(params[:plan])
      redirect_to plans_path, :notice => 'Plan was successfully updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /plans/1
  def destroy
    @plan = Plan.find(params[:id])
    @plan.destroy
    redirect_to plans_url
  end

private
  def get_plan_categories_for_select
    PlanCategory.all.map {|c| [c.name, c.id]}
  end

end
