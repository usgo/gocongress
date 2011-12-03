class EventCategoriesController < ApplicationController

  load_and_authorize_resource

  def show
    events = @event_category.events.order "start asc"
    @events_by_date = events.group_by {|event| event.start.to_date}
  end
end
