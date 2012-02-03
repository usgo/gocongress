class EventCategoriesController < ApplicationController

  load_and_authorize_resource

  def create
    @event_category.year = @year
    if @event_category.save
      redirect_to(@event_category, :notice => 'Category created.')
    else
      render :action => "new"
    end
  end

  def destroy
    @event_category.destroy
    redirect_to event_categories_path
  end

  def show
    activities = @event_category.activities.order "start asc"
    @activities_by_date = activities.group_by {|activity| activity.start.to_date}
  end

  def update
    if @event_category.update_attributes(params[:event_category])
      redirect_to event_category_path(@event_category), :notice => 'Category updated.'
    else
      render :action => "edit"
    end
  end

end
