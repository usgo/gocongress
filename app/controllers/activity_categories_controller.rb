class ActivityCategoriesController < ApplicationController
  include YearlyController

  load_and_authorize_resource

  def create
    @activity_category.year = @year.year
    if @activity_category.save
      redirect_to(@activity_category, :notice => 'Category created.')
    else
      render :action => "new"
    end
  end

  def destroy
    @activity_category.destroy
    redirect_to activity_categories_path
  end

  def show
    activities = @activity_category.activities.order :leave_time
    @activities_by_date = activities.group_by {|activity| activity.leave_time.to_date}
  end

  def update
    if @activity_category.update_attributes(params[:activity_category])
      redirect_to activity_category_path(@activity_category), :notice => 'Category updated.'
    else
      render :action => "edit"
    end
  end

end
