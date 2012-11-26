class ActivitiesController < ApplicationController
  include DollarController
  include YearlyController

  # Callbacks, in order
  add_filter_converting_param_to_cents :price
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

  # Actions
  def create
    @activity.year = @year.year
    if @activity.save
      redirect_to @activity, :notice => "#{Activity.model_name.human} created"
    else
      render :action => "new"
    end
  end

  def update
    if @activity.update_attributes(params[:activity])
      redirect_to @activity, :notice => "#{Activity.model_name.human} updated"
    else
      render :action => "edit"
    end
  end

  def destroy
    @activity.destroy
    redirect_to activity_category_url @activity.activity_category
  end

  # Helpers
  def activity_category_options
    ActivityCategory.yr(@year).all.map {|c| [ c.name, c.id ] }
  end
  helper_method :activity_category_options

end
