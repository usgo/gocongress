class PlansController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def new
    @plan_categories = categories_for_select
  end

  def edit
    @plan_categories = categories_for_select
  end

  def create
    @plan.year = @year
    @plan_categories = categories_for_select
    if @plan.save
      redirect_to plan_category_path(@plan.plan_category), :notice => 'Plan created.'
    else
      render :action => "new"
    end
  end

  def update
    @plan_categories = categories_for_select
    if @plan.update_attributes(params[:plan])
      redirect_to plan_category_path(@plan.plan_category), :notice => 'Plan updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    begin
      @plan.destroy
      flash[:notice] = "Plan deleted"
    rescue ActiveRecord::DeleteRestrictionError => e
      @plan.errors.add(:base, e)
      flash[:alert] = "Cannot delete plan because attendees have already selected it"
    ensure
      redirect_to plan_category_path(@plan.plan_category)
    end
  end

private

  def categories_for_select
    PlanCategory.yr(@year).order(:name).all.map {|c| [c.name, c.id]}
  end

end
