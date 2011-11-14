class EventsController < ApplicationController

  load_and_authorize_resource

  # GET /events
  def index
    events = @events.where(:year => @year).order "start asc"
    @events_by_date = events.group_by {|event| event.start.to_date}
  end

  # GET /events/1
  def show
  end

  # GET /events/new
  def new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @event.year = @year
    if @event.save
      redirect_to @event, :notice => 'Event created.'
    else
      render :action => "new"
    end
  end

  # PUT /events/1
  def update
    if @event.update_attributes(params[:event])
      redirect_to @event, :notice => 'Event updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    redirect_to events_url
  end
end
