class ActivityCategoriesController < ApplicationController
  include YearlyController

  # Callbacks, in order
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route
  before_action :deny_users_from_wrong_year, :except => [:show]

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

  def index
    # The following filter on year is redundant because, unlike
    # content categories, guests cannot currently index activity
    # categories.  (see ability.rb)  That's the sort of thing that
    # could easily change in the future though, so it makes sense
    # to have a redundant filter here. -Jared 2012-08-29
    @activity_categories = @activity_categories.yr(@year)
  end

  def show
    activities = @activity_category.activities.order('leave_time, name')
    @activities_by_date = activities.group_by {|activity| activity.leave_time.to_date}
  end

  def update
    if @activity_category.update_attributes!(activity_category_params)
      redirect_to activity_category_path(@activity_category), :notice => 'Category updated.'
    else
      render :action => "edit"
    end
  end

  private

  def activity_category_params
    params.require(:activity_category).permit(:description, :name)
  end
end
