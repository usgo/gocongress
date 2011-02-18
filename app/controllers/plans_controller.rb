class PlansController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:index]

  # GET /plans
  def index
    plans_ordered = Plan.all :order=>"has_rooms desc"
    @plans_grouped = plans_ordered.group_by {|plan| plan.has_rooms}
  end

  # GET /plans/1
  def show
    @plan = Plan.find(params[:id])
  end

  # GET /plans/new
  def new
    @plan = Plan.new
  end

  # GET /plans/1/edit
  def edit
    @plan = Plan.find(params[:id])
  end

  # POST /plans
  def create
    @plan = Plan.new(params[:plan])
    if @plan.save
      redirect_to plans_path, :notice => 'Plan was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /plans/1
  def update
    @plan = Plan.find(params[:id])
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
end
