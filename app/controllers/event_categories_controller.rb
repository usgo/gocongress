class EventCategoriesController < ApplicationController

  load_and_authorize_resource

  def show
    events = @event_category.events.order "start asc"
    @events_by_date = events.group_by {|event| event.start.to_date}
  end

  def update
    if @event_category.update_attributes(params[:event_category])
      redirect_to event_category_path(@event_category), :notice => 'Category updated.'
    else
      render :action => "edit"
    end
  end

end
